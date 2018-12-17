///
module telega.updates;

import telega.botapi;
import std.range.interfaces;

/// Incoming messages
class Updates : InputRange!Update
{
    private BotApi botConn;
    private Update[] incoming;
    private size_t index;

    package this(Update[] upd, BotApi conn)
    {
        incoming = upd;
        botConn = conn;
    }

    ~this()
    {
        botConn.updatesProcessingInProgress = false;
    }

    Update front() @property
    {
        return incoming[index];
    }

    bool empty() @property { return index >= incoming.length; }
    void popFront()
    {
        botConn.updateProcessed(front.id);
        index++;
    }

    int opApply(scope int delegate(Update)){ assert(false, "Not implemented"); }
    int opApply(scope int delegate(size_t, Update)){ assert(false, "Not implemented"); }
    Update moveFront() { assert(false, "Not implemented"); }
}
