///
module telega.updates;

import telega.botapi;
import std.range.interfaces;

/// Incoming messages
class Updates : InputRange!Update
{
    private BotApi botConn;
    private alias UpdatesRange = InputRangeObject!(Update[]);
    private UpdatesRange incoming;

    package this(Update[] upd, BotApi conn)
    {
        incoming = inputRangeObject(upd);
        botConn = conn;
    }

    Update front() @property
    {
        return incoming.front;
    }

    bool empty() @property { return incoming.empty; }
    void popFront() { incoming.popFront; }

    int opApply(scope int delegate(Update)){ assert(false, "Not implemented"); }
    int opApply(scope int delegate(size_t, Update)){ assert(false, "Not implemented"); }
    Update moveFront() { assert(false, "Not implemented"); }
}
