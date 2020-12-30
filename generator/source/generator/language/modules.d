module generator.language.modules;

import std.conv : to;
import std.algorithm.iteration : map;
import std.string : format;
import std.array : join;
import std.stdio;

class Module
{
    private ModuleDeclaration moduleDeclaration;
    private DeclDef[] declDefs;

    public this(string moduleFullyQualifiedName)
    {
        moduleDeclaration = new ModuleDeclaration(moduleFullyQualifiedName);
    }

    public void addDeclDef(DeclDef declDef)
    {
        declDefs ~= declDef;
    }

    public override string toString()
    {
        writefln("%s = %d", moduleDeclaration.moduleFullyQualifiedName, declDefs.length);
        return format("%s\n%s", moduleDeclaration.to!string, declDefs.map!(dd => dd.to!string).join("\n"));
    }
}

class ModuleDeclaration
{
    private ModuleAttribute[] moduleAttributes;
    private string moduleFullyQualifiedName;

    public this(string moduleFullyQualifiedName)
    {
        assert(moduleFullyQualifiedName);
        this.moduleFullyQualifiedName = moduleFullyQualifiedName;
    }

    public override string toString()
    {
        return format(
            "%s module %s;",
            moduleAttributes.length > 0 ? moduleAttributes.map!(ma => ma.to!string).join("\n") : "",
            moduleFullyQualifiedName
        );
    }
}

class ModuleAttribute
{

}

class DeclDef
{
    public override string toString()
    {
        return "DeclDef";
    }
}
