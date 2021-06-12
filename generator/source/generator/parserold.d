module generator.parserold;

import arsd.dom : Document, Element;
import std.stdio : writeln, writefln;
import std.string : format, replace;
import std.uni : isLower, toLower;
import std.algorithm.searching : until;
import std.algorithm.comparison : among;
import std.range : generate;

import generator.parser.entity : TelegramEntity, TelegramType, TypeField, TelegramMethod,
    MethodParameter, Section;
import generator.parser.html : DivDevPageContent;

bool isTelegramMethod(Element h4)
{
    return h4.directText[0].isLower;
}

class TelegramBotApiHTMLParser
{
    private HtmlEntityParser htmlEntityParser;
    private TelegramEntity[string] entities;

    public this()
    {
        htmlEntityParser = new HtmlEntityParser;
    }

    public DivDevPageContent parseDocument(Document document)
    {
        auto divDevPageContent = new DivDevPageContent();
        auto firstH3Element = document.getFirstElementByTagName("p");
        auto h3section = new H3Section(firstH3Element.directText);
        divDevPageContent.h3sections ~= h3section;
        
        return divDevPageContent;
    }

    public Section parseSection(Element h3)
    {
        Section s = new Section(h3.directText);
        writefln(`Parsing section "%s"`, s.title);
        writeln("\n-----------------------------------");

        for (Element el = h3.nextElementSibling; el !is null && el.tagName != "h3"; el = el.nextElementSibling) {
            if (el.tagName == "h4") {
                TelegramEntity entity = this.htmlEntityParser.parseEntity(el);
                if (entity !is null) {
                    entities[entity.id] = entity;
                    s.addEntity(entity);
                } else {
                    writeln("  Skipping entity");
                }
            }
        }

        return s;
    }

    public auto getEntities()
    {
        return entities;
    }
}

class TelegramBotApiTypeHTMLParser
{
    class CommonTypeParser
    {
        protected Element parseDescription(Element p, TelegramType entity)
        {
            Element currentElement = p;
            while(!currentElement.tagName.among("table", "h4")) {
                parseDescriptionTag(currentElement, entity);
                currentElement = currentElement.nextElementSibling;
            }
            debug writefln("    Description: %s", entity.description);

            return currentElement;
        }

        protected void parseDescriptionTag(Element e, TelegramType entity)
        {
            switch (e.tagName) {
                case "p":
                    if (entity.description.length > 0) {
                        entity.description ~= "\n";
                    }
                    entity.description ~= e.directText;
                    break;
                case "blockquote":
                    break;
                default:
                    assert(0, format("Unexpected tag: %s", e.tagName));
            }
        }

        private Element parseNote(Element blockquote, out TelegramType entity)
        {
            assert(0, "Unexpected parseNote call");
        }

        private Element parseFields(Element e, out TelegramType entity)
        {
            assert(0, "Unexpected parseFields call");
        }
    }

    class AggregateTypeParser : CommonTypeParser
    {
        protected override Element parseDescription(Element p, TelegramType entity)
        {
            while (p.tagName != "table") {
                p = p.nextElementSibling;
            }

            return p;
        }
    }

    class LoginUrlTypeParser : CommonTypeParser
    {
        protected override void parseDescriptionTag(Element e, TelegramType entity)
        {
            if (e.tagName == "div") {
                return;
            }
            super.parseDescriptionTag(e, entity);
        }
    }

    private CommonTypeParser commonTypeParser;
    private AggregateTypeParser aggregateTypeParser;
    private LoginUrlTypeParser loginUrlTypeParser;

    public this()
    {
        commonTypeParser = new CommonTypeParser;
        aggregateTypeParser = new AggregateTypeParser;
        loginUrlTypeParser = new LoginUrlTypeParser;
    }

    public TelegramType opCall(Element h4, string id, string name)
    {
        auto entity = new TelegramType(id, name);
        Element currentElement = h4.nextElementSibling;
        switch (id) {
            case "loginurl":
                currentElement = loginUrlTypeParser.parseDescription(currentElement, entity);
                break;

            case "inputmedia":
            case "inlinequeryresult":
            case "inputmessagecontent":
            case "passportelementerror":
                entity.isMeta = true;
                currentElement = aggregateTypeParser.parseDescription(currentElement, entity);
                break;

            case "inputfile":
            case "sending-files":
            case "inline-mode-objects":
            case "formatting-options":
            case "inline-mode-methods":
                return null;

            case "callbackgame":
                commonTypeParser.parseDescription(currentElement, entity);
                return entity;

            default:
                currentElement = commonTypeParser.parseDescription(currentElement, entity);
        }

        Element tableFields = currentElement;

        assert(tableFields.tagName == "table", format("Unexpected tag %s, expected %s", tableFields.tagName, "table"));

        Element[] rows = tableFields.querySelector("tbody").querySelectorAll("tr");
        foreach (Element row; rows) {
            auto columns = row.querySelectorAll("td");
            debug writefln("    Field: %s, type: %s, description: %s", columns[0].directText,
                this.parseFieldType(columns[1]),
                columns[2].directText
            );
        }

        return entity;
    }

    private string parseFieldType(Element td)
    {
        if (td.directText.length == 0) {
            return "LINK";
        }

        return td.directText;
    }
}

class TelegramBotApiMethodHTMLParser
{
    public TelegramMethod opCall(Element h4, string id, string name)
    {
        auto entity = new TelegramMethod(id, name);

        return entity;
    }
}

class HtmlEntityParser
{
    private TelegramBotApiTypeHTMLParser typeParser;
    private TelegramBotApiMethodHTMLParser methodParser;

    public this()
    {
        typeParser = new TelegramBotApiTypeHTMLParser;
        methodParser = new TelegramBotApiMethodHTMLParser;
    }

    public TelegramEntity parseEntity(Element h4)
    {
        const Element a = h4.querySelector("a");
        const id = a.getAttribute("name");
        const name = h4.directText;

        debug {
            writeln;
            writefln("  Parsing h4: %s, id: %s", h4.directText, id);
            const href = a.getAttribute("href");
            assert(id == href[1..$], format(`h4 element href "%s" does not correspond to name "%s"`, href, id));
            assert(
                id == name.toLower.replace(" ", "-"),
                format(`h4 element with name %s does not correspond to title %s`, id, name)
            );
        }

        if (h4.isTelegramMethod) {
            return methodParser(h4, id, name);
        }

        return typeParser(h4, id, name);
    }
}
