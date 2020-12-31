module generator.language.declarations;

import std.string : format;
import std.uni : toLower;
import std.algorithm.iteration : map;
import std.conv : to;
import generator.language.modules : DeclDef;

class Declaration : DeclDef
{

}

class VarDeclarations : Declaration
{
    //private StorageClass[] storageClasses;
    private BasicType basicType;
    private Declarators declarators;

    public this (BasicType basicType, Declarators declarators)
    {
        this.basicType = basicType;
        this.declarators = declarators;
    }

    public override string toString()
    {
        return format("%s %s;", basicType, declarators);
    }
}

class Declarators
{
    private DeclaratorInitializer declaratorInitializer;

    public this(DeclaratorInitializer di)
    {
        declaratorInitializer = di;
    }

    public override string toString()
    {
        return declaratorInitializer.to!string;
    }
}

class DeclaratorInitializer
{
    private VarDeclarator varDeclarator;

    public this(VarDeclarator vd)
    {
        varDeclarator = vd;
    }

    public override string toString()
    {
        return varDeclarator.to!string;
    }
}

class VarDeclarator
{
    // private type suffixes
    private string identifier;

    public this(string identifier)
    {
        this.identifier = identifier;
    }

    public override string toString()
    {
        return identifier;
    }
}

class AggregateDeclaration : Declaration
{

}

class StorageClass
{

}

class DeclaratorIdentifierList
{

}

class Type
{

}

class BasicType
{

}

enum FundamentalTypeEnum
{
    Bool,
    Byte,
    Ubyte,
    Short,
    Ushort,
    Int,
    Uint,
    Long,
    Ulong,
    Cent,
    Ucent,
    Char,
    Wchar,
    Dchar,
    Float,
    Double,
    Real,
    Ifloat,
    Idouble,
    Ireal,
    Cfloat,
    Cdouble,
    Creal,
    Void,
}

class FundamentalType : BasicType
{
    private FundamentalTypeEnum value;

    public this(FundamentalTypeEnum value)
    {
        this.value = value;
    }

    public override string toString()
    {
        return value.to!string.toLower();
    }
}
