module generator.parser.entity;

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