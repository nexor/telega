module telega.serialization;

import std.traits;
import std.typecons;
import std.meta : AliasSeq, staticIndexOf;
import asdf;

string serializeToJsonString(T)(T value)
{
    return serializeToJson(value);
}

unittest
{
    import std.typecons;

    alias FewTypes = AliasSeq!(int, string);

    struct S
    {
        JsonableAlgebraicProxy!FewTypes a;
    }

    S s;
    s.a = 42;

    assert(`{"a":42}` == s.serializeToJson());

    s.a = "123";
    assert(`{"a":"123"}` == s.serializeToJson());
}

import std.traits;

enum isNullable(T) = __traits(isSame, TemplateOf!T, Nullable);

string serializeSkipNulls(T)(T value)
{
    import std.conv;
    auto root = AsdfNode(`{}`.parseJson);

    static foreach(ulong i, string member; __traits(allMembers, T)) {
        static if ( !isNullable!(typeof(T.tupleof[i])) ) {
            root[member] = AsdfNode(__traits(getMember, value, member).serializeToAsdf());
        } else {
            if (!__traits(getMember, value, member).isNull) {
                root[member] = AsdfNode(__traits(getMember, value, member).serializeToAsdf());
            }
        }
    }

    return (cast(Asdf)root).to!string;
}

unittest
{
    struct S
    {
        int a;
        Nullable!int b;
        Nullable!string c;
    }

    S s;
    s.a = 42;
    s.c = "cvalue";

    import std.stdio;
    auto serialized = serializeSkipNulls(s);
    writeln(serialized);

    assert(serialized == `{"c":"cvalue","a":42}`);
}

struct JsonableAlgebraicProxy(Typelist ...)
{
    import std.variant;
    import asdf;

    private Algebraic!Typelist value;

    //alias value this;

    void opAssign(T)(T value)
        if (staticIndexOf!(T, Typelist) >= 0)
    {
        this.value = value;
    }

    static Algebraic!Typelist deserialize(Asdf data)
    {
        assert(false, "Deserialization of a value is not implemented.");
    }

    void serialize(S)(ref S serializer)
    {
        if (!value.hasValue) {
            serializer.putValue(null);

            return;
        }

        static foreach (T; Typelist) {
            if (value.type == typeid(T)) {
                T result = cast(T)value.get!T;

                serializer.serializeValue(result);
            }
        }
    }
}
