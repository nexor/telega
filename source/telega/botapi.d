module telega.botapi;

import vibe.core.log;
import asdf : Asdf, serializedAs;
import asdf.serialization : deserialize;
import std.typecons : Nullable;
import std.exception : enforce;
import telega.exception : TelegramException;
import std.traits : isSomeString, isIntegral;
import telega.http : HttpClient;
import telega.serialization : serializeToJsonString, JsonableAlgebraicProxy;

version (unittest)
{
    import telega.test : assertEquals;
}

enum HTTPMethod
{
	GET,
	POST
}

@serializedAs!ChatIdProxy
struct ChatId
{
    import std.conv;

    string id;

    private bool _isString = true;

    alias id this;

    this(long id)
    {
        this.id = id.to!string;
        _isString = false;
    }

    this(string id)
    {
        this.id = id;
    }

    void opAssign(long id)
    {
        this.id = id.to!string;
        _isString = false;
    }

    void opAssign(string id)
    {
        this.id = id;
        _isString = true;
    }

    @property
    bool isString()
    {
        return _isString;
    }

    long opCast(T)()
        if (is(T == long))
    {
        if (_isString) {
            return 0;
        }

        return id.to!long;
    }
}

struct ChatIdProxy
{
    ChatId id;

    this(ChatId id)
    {
        this.id = id;
    }

    ChatId opCast(T : ChatId)()
    {
        return id;
    }

    static ChatIdProxy deserialize(Asdf v)
    {
        return ChatIdProxy(ChatId(cast(string)v));
    }
}

unittest
{
    ChatId chatId;

    chatId = 45;
    chatId.isString()
        .assertEquals(false);

    chatId = "@chat";
    chatId.isString()
        .assertEquals(true);

    string chatIdString = chatId;
    chatIdString
        .assertEquals("@chat");

    long chatIdNum = cast(long)chatId;
    chatIdNum
        .assertEquals(0);

    chatId = 42;

    chatIdNum = cast(long)chatId;
    chatIdNum
        .assertEquals(42);

    string chatIdFunc(ChatId id)
    {
        return id;
    }

    chatIdFunc(cast(ChatId)"abc")
        .assertEquals("abc");
    chatIdFunc(cast(ChatId)45)
        .assertEquals("45");
}


class TelegramBotApiException : TelegramException
{
    /// Telegram bot API code (not to be confused with HTTP codes)
    ushort code;

    this(ushort code, string description, string file = __FILE__, size_t line = __LINE__,
         Throwable next = null) @nogc @safe pure nothrow
    {
        this.code = code;
        super(description, next, file, line);
    }
}

enum isTelegramId(T) = isSomeString!T || isIntegral!T || is(T == ChatId);

mixin template TelegramMethod(string path, HTTPMethod method = HTTPMethod.POST)
{
    import asdf.serialization : serializationIgnore;

    public:
        @serializationIgnore
        immutable string      _path       = path;

        @serializationIgnore
        immutable HTTPMethod  _httpMethod = method;
}

/// UDA for telegram methods
struct Method
{
    string path;
}

/******************************************************************/
/*                          Telegram API                          */
/******************************************************************/

enum BaseApiUrl = "https://api.telegram.org/bot";

class BotApi
{
    private:
        string baseUrl;
        string apiUrl;

        ulong requestCounter = 1;

        struct MethodResult(T)
        {
            bool   ok;
            T      result;
            ushort error_code;
            string description;
        }

    protected:
        HttpClient httpClient;

    public:
        this(string token, string baseUrl = BaseApiUrl, HttpClient httpClient = null)
        {
            this.baseUrl = baseUrl;
            this.apiUrl = baseUrl ~ token;

            if (httpClient is null) {
                version(TelegaVibedDriver) {
                    import telega.drivers.vibe;

                    httpClient = new VibedHttpClient();
                } else version(TelegaRequestsDriver) {
                    import telega.drivers.requests;

                    httpClient = new RequestsHttpClient();
                } else {
                    assert(false, `No HTTP client is set, maybe you should enable "default" configuration?`);
                }
            }
            this.httpClient = httpClient;
        }

        T callMethod(T, M)(M method)
        {
            T result;

            logDebug("[%d] Requesting %s", requestCounter, method._path);

            version(unittest)
            {
                import std.stdio;
                serializeToJsonString(method).writeln();
            } else {
                string answer;

                if (method._httpMethod == HTTPMethod.POST) {
                    string bodyJson = serializeToJsonString(method);
                    logDebugV("[%d] Sending body:\n  %s", requestCounter, bodyJson);

                    answer = httpClient.sendPostRequestJson(apiUrl ~ method._path, bodyJson);
                } else {
                    answer = httpClient.sendGetRequest(apiUrl ~ method._path);
                }

                logDebugV("[%d] Data received:\n %s", requestCounter, answer);

                auto json = answer.deserialize!(MethodResult!T);

                enforce(json.ok == true, new TelegramBotApiException(json.error_code, json.description));

                result = json.result;
                requestCounter++;
            }

            return result;
        }
}
