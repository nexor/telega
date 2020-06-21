module telega.serialization;

import std.meta : AliasSeq, staticIndexOf;
import asdf : Asdf, serializeValue, serializeToAsdf, serializeToJson, parseJson;

string serializeToJsonString(T)(T value)
{
    import std.conv : to;

    Asdf asdf = serializeToAsdf(value);
    removeNulledNodes(asdf);

    return  asdf.to!string;
}

unittest
{
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

void removeNulledNodes(ref Asdf a)
{
    if (a.kind == Asdf.Kind.null_) {
        a.remove();
    } else if (a.kind == Asdf.Kind.array) {
        foreach (v; a.byElement) {
            removeNulledNodes(v);
        }
    } else if (a.kind == Asdf.Kind.object) {
        foreach (kv; a.byKeyValue) {
            removeNulledNodes(kv.value);
        }
    }
}

unittest
{
    import std.conv: to;

    string jsonWithNulls = `{
        "chat_id":"100000001",
        "text":"o",
        "reply_markup":{
            "keyboard":[
                [
                    {"text":"First Button","request_contact":null,"request_location":null},
                    {"text":"Second Button","request_contact":null,"request_location":null}
                ],
                [
                    {"text":"Ask location","request_contact":false,"request_location":true}
                ],
                [
                    {"text":"Remove Keyboard","request_contact":null,"request_location":null}
                ]
            ],
            "resize_keyboard":false,
            "selective":false,
            "one_time_keyboard":false
        }
    }`;
    const string cleanJson = `{
        "chat_id":"100000001",
        "text":"o",
        "reply_markup":{
            "keyboard":[
                [
                    {"text":"First Button"},
                    {"text":"Second Button"}
                ],
                [
                    {"text":"Ask location","request_contact":false,"request_location":true}
                ],
                [
                    {"text":"Remove Keyboard"}
                ]
            ],
            "resize_keyboard":false,
            "selective":false,
            "one_time_keyboard":false
        }
    }`;

    Asdf asdf = jsonWithNulls.parseJson();

    removeNulledNodes(asdf);

    assert(asdf.to!string == cleanJson.parseJson.to!string);
}

struct JsonableAlgebraicProxy(Typelist ...)
{
    import std.variant : Algebraic;

    private Algebraic!Typelist value;

    this(T)(T value)
        if (staticIndexOf!(T, Typelist) >= 0)
    {
        opAssign(value);
    }

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

unittest
{
    struct A {
        int val;
    }

    alias AProxy = JsonableAlgebraicProxy!A;

    AProxy[] aelements;

    assert(__traits(compiles, aelements ~= cast(AProxy)A(3)));
}
