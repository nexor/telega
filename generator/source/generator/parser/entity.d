module generator.parser.entity;

class TelegramEntity
{
    public immutable string id, name;
    public string description, note;
    /// blockquote tag content
    
    public this(string id, string name)
    {
        this.id = id;
        this.name = name;
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