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

        for (Element el = h3.nextElementSibling; el !is null && el.tagName != "h3"; el = el.nextElementSibling) {
            if (el.tagName == "h4") {
                TelegramEntity entity = this.htmlEntityParser.parseEntity(el);
                writefln(`  Parsing entity %s`, entity.name);

                entities[entity.id] = entity;
                s.addEntity(entity);
            }
        }

        return s;
    }

    public auto getEntities()
    {
        return entities;
    }
}

class HtmlEntityParser
{
    public TelegramEntity parseEntity(Element h4)
    {
writeln(h4);
        const Element a = h4.querySelector("a");
        const id = a.getAttribute("name");
        const name = h4.directText;

        debug {
            const href = a.getAttribute("href");
            assert(id == href[1..$], format(`h4 element href "%s" does not correspond to name "%s"`, href, id));
            assert(
                id == name.toLower.replace(" ", "-"),
                format(`h4 element with name %s does not correspond to title %s`, id, name)
            );
        }

        if (h4.isTelegramMethod) {
            return parseMethod(h4, id, name);
        }

        return parseType(h4, id, name);
    }

    private TelegramMethod parseMethod(Element h4, string id, string name)
    {
        auto entity = new TelegramMethod(id, name);


        return entity;
    }

    private TelegramType parseType(Element h4, string id, string name)
    {
        auto entity = new TelegramType(id, name);
        Element pDescription = h4.nextElementSibling;
        assert(pDescription.tagName == "p", format("%s is not a valid description tag", pDescription.tagName));
        Element tableFields = pDescription.nextElementSibling;
        assert(tableFields.tagName == "table", format("Unextpected tag %s, expected %s", tableFields.tagName, "table"));

        entity.description = pDescription.directText;
        Element[] rows = tableFields.querySelector("tbody").querySelectorAll("tr");
        foreach (Element row; rows) {
            auto columns = row.querySelectorAll("td");
            writefln("Field: %s, type: %s, description: %s", columns[0].directText,
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

class TelegramEntity
{
    public string description;

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
