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
