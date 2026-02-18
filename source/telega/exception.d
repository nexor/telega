module telega.exception;

class TelegramException : Exception
{
    this(string msg, Throwable nextInChain = null, string file = __FILE__, size_t line = __LINE__) @nogc @safe pure nothrow
    {
        super(msg, nextInChain, file, line);
    }
}
