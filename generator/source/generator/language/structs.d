module generator.language.structs;

import std.string : format;
import std.conv : to;
import std.algorithm.iteration : map;
import std.array : join;

class StructDeclaration
{
    private string identifier;
    private AggregateBody _aggregateBody;

    public this(string identitier)
    {
        this.identifier = identifier;
        _aggregateBody = new AggregateBody;
    }

    public AggregateBody aggregateBody()
    {
        return _aggregateBody;
    }

    public override string toString()
    {
        return format(`struct %s 
{
    %s
}`, identifier, _aggregateBody.to!string);
    }
}

class AggregateBody
{
    private DeclDef[] declDefs;

    public AggregateBody addDeclDef(DeclDef declDef)
    {
        declDefs ~= declDef;

        return this;
    }

    public override string toString()
    {
        return declDefs.map!(dd => dd.to!string).join("\n    ");
    }
}

class DeclDef
{
    public override string toString()
    {
        return "DeclDef";
    }
}

class Declaration : DeclDef
{

}