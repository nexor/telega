module telega.serialization;

import std.traits;
import std.typecons;
import std.meta : AliasSeq, staticIndexOf;
import asdf;

string serializeToJsonString(T)(T value)
{
    import std.conv : to;

    AsdfNode asdfNode = serializeToAsdf(value);
    removeNulledNodes(asdfNode);

    return  asdfNode.serializeToAsdf.to!string;
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

void removeNulledNodes(ref AsdfNode an)
{
    foreach (ref v; an.children) {
        if (!v.isLeaf) {
            removeNulledNodes(v);
        } else if (v.data.kind == Asdf.Kind.null_) {
            v.data.remove();
        }
    }
}

unittest
{
    import std.conv: to;

    struct Payload
    {
        bool val;
        Nullable!bool nullablePayloadItem;
    }

    struct Message
    {
        string stringText;

        Nullable!Payload nullablePayload;
        Payload notNullablePayload;

        Nullable!int nullableInt;
        int notNullableInt;
    }

    Message m;
    AsdfNode an = AsdfNode(m.serializeToAsdf());

    assert(an.serializeToAsdf.to!string ==
        `{"nullablePayload":null,"notNullablePayload":{"val":false,"nullablePayloadItem":null},"notNullableInt":0,"stringText":null,"nullableInt":null}`
    );

    removeNulledNodes(an);

    assert(an.serializeToAsdf.to!string ==
        `{"notNullablePayload":{"val":false},"notNullableInt":0}`
    );
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
            serializer.putValue("{}");

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
