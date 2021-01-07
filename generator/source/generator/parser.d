module generator.parser;

import arsd.dom : Element;
import std.stdio : writeln, writefln;
import std.string : format, replace;
import std.uni : isLower, toLower;
import std.algorithm.searching : until;
import std.range : generate;

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
                    writeln("Skipping entity");
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
            while(currentElement.tagName != "table") {
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

    class MetaTypeParser : CommonTypeParser
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
    private MetaTypeParser metaTypeParser;
    private LoginUrlTypeParser loginUrlTypeParser;

    public this()
    {
        commonTypeParser = new CommonTypeParser;
        metaTypeParser = new MetaTypeParser;
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
                entity.isMeta = true;
                currentElement = metaTypeParser.parseDescription(currentElement, entity);
                break;

            case "inputfile":
            case "sending-files":
                return null;

            default:
                currentElement = commonTypeParser.parseDescription(currentElement, entity);
        }

        Element tableFields = currentElement;

        assert(tableFields.tagName == "table", format("Unextpected tag %s, expected %s", tableFields.tagName, "table"));

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

class TelegramEntity
{
    public string description;
    /// blockquote tag content
    public string note;

    private string _id;
    private string _name;
    
    public this(string id, string name)
    {
        _id = id;
        _name = name;
    }

    @property
    public string id()
    {
        return _id;
    }

    @property
    public string name()
    {
        return _name;
    }
}

class TelegramType : TelegramEntity
{
    private TypeField[] fields;
    private bool isMeta = false;

    public this(string id, string name)
    {
        super(id, name);
    }

    public void addField(TypeField field)
    {
        fields ~= field;
    }
}

struct TypeField
{
    public string field;

    public bool isArray;
    public string type;
    public string complexTypeId;

    public string description;

    public bool isOptional()
    {
        return true;
    }
}

class TelegramMethod : TelegramEntity
{
    public this(string id, string name)
    {
        super(id, name);
    }
}

struct MethodParameter
{
    string parameter;
    string type;
    bool required;
    string description;
}

class Section
{
    string title;
    TelegramType[] types;
    TelegramMethod[] methods;

    public this(string title)
    {
        this.title = title;
    }

    public void addEntity(TelegramEntity entity)
    {
        if (cast(TelegramMethod)entity) {
            methods ~= cast(TelegramMethod)entity;
        }
        if (cast(TelegramType)entity) {
            types ~= cast(TelegramType)entity;
        }
    }
}
