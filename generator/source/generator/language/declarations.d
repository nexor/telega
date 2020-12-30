module generator.language.declarations;

import std.string : format;
import std.algorithm.iteration : map;
import std.conv : to;
import generator.language.modules : DeclDef;

class Declaration : DeclDef
{

}

class VarDeclarations : Declaration
{
    private StorageClass[] storageClasses;
    private BasicType basicType;
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
        return value.to!string;
    }
}

