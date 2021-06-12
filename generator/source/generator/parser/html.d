module generator.parser.html;

class DivDevPageContent
{
    H3Section[] h3sections;
}

class H3Section
{
    public immutable string title;

    public this(string title)
    {
        this.title = title;
    }

    H4Section[] h4sections;
}

class H4Section
{

}