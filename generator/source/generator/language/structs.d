module generator.language.structs;

import std.stdio;
import std.string : format;
import std.conv : to;
import std.algorithm.iteration : map;
import std.array : join;
import generator.language.modules;
import generator.language.declarations : AggregateDeclaration;

class StructDeclaration : AggregateDeclaration
{
    private string identifier;
    private AggregateBody _aggregateBody;

    public this(string identitier)
    {
        assert(identifier.length);

        this.identifier = identifier;
        _aggregateBody = new AggregateBody;
    }

    public AggregateBody aggregateBody()
    {
        return _aggregateBody;
    }

    public override string toString()
    {
        writefln(":: %s", identifier);
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
