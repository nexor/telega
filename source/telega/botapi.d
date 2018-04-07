module telega.botapi;

import vibe.http.client;
import vibe.stream.operations;
import vibe.core.core;
import vibe.core.log;
import asdf;
import std.conv;
import std.typecons;
import std.exception;

class TelegramBotApiException : Exception
{
    ushort code;

    this(ushort code, string description, string file = __FILE__, size_t line = __LINE__,
         Throwable next = null) @nogc @safe pure nothrow
    {
        this.code = code;
        super(description, file, line, next);
    }
}

/******************************************************************/
/*                    Telegram types and enums                    */
/******************************************************************/

struct User
{
    int    id;
    bool   is_bot;
    string first_name;
    string last_name;
    string username;
    string language_code;
}

enum ChatType : string
{
    Private    = "private",
    Group      = "group",
    Supergroup = "supergroup",
    Channel    = "channel"
}

struct Chat
{
	long            id;
	string          type;
    string title;
    string first_name;
	string last_name;
	string username;
}

struct Message
{
    uint                 message_id;
    uint                 date;
    Chat                 chat;
    Nullable!User        from;
    string      last_name;
    string      username;
    string      language_code;
    string      text;
    Nullable!PhotoSize[] photo;
}

struct Update
{
    uint             update_id;
    Nullable!Message message;

    @property
    uint id()
    {
        return update_id;
    }
}

enum ParseMode
{
    Markdown = "Markdown",
    HTML     = "HTML",
    None     = "",
}

struct PhotoSize
{
    string        file_id;
    int           width;
    int           height;

    Nullable!uint file_size;
}

/******************************************************************/
/*                        Telegram methods                        */
/******************************************************************/

mixin template TelegramMethod()
{
    package:
        HTTPMethod httpMethod = HTTPMethod.POST;
}

struct GetUpdatesMethod
{
    mixin TelegramMethod;

    package
    string name = "/getUpdates";

    int   offset;
    ubyte limit;
    uint  timeout;
}

struct GetMeMethod
{
    mixin TelegramMethod;

    package
    string name = "/getMe";
}

struct SendMessageMethod
{
    mixin TelegramMethod;

    package
    string name = "/sendMessage";

    string    chat_id;
    string    text;
    ParseMode parse_mode;
}

/******************************************************************/
/*                          Telegram API                          */
/******************************************************************/

class BotApi
{
    private:
        string baseUrl = "https://api.telegram.org/bot";
        string apiUrl;

        ulong requestCounter = 1;
        uint maxUpdateId = 1;

        struct MethodResult(T)
        {
            bool   ok;
            T      result;
            ushort error_code;
            string description;
        }

    public:
        this(string token)
        {
            this.apiUrl = baseUrl ~ token;
        }

        void updateProcessed(int updateId)
        {
            if (updateId >= maxUpdateId) {
                maxUpdateId = updateId + 1;
            }
        }

        void updateProcessed(ref Update update)
        {
            updateProcessed(update.id);
        }

        T callMethod(T, M)(M method)
        {
            T result;

            logDiagnostic("[%d] Requesting %s", requestCounter, method.name);

            requestHTTP(apiUrl ~ method.name,
                (scope req) {
                    req.method = method.httpMethod;
                    if (method.httpMethod == HTTPMethod.POST) {
                        logDebugV("[%d] Sending body:\n  %s", requestCounter, method.serializeToJson());
                        req.headers["Content-Type"] = "application/json";
                        req.writeBody( cast(const(ubyte[])) serializeToJson(method) );
                    }
                },
                (scope res) {
                    string answer = res.bodyReader.readAllUTF8(true);
                    logDebug("[%d] Response headers:\n  %s\n  %s", requestCounter, res, res.headers);
                    logDiagnostic("[%d] Response body:\n  %s", requestCounter, answer);

                    auto json = answer.deserialize!(MethodResult!T);

                    enforce(json.ok == true, new TelegramBotApiException(json.error_code, json.description));

                    result = json.result;

                    requestCounter++;
                }
            );

            return result;
        }

        Update[] getUpdates(ubyte limit = 5, uint timeout = 30)
        {
            GetUpdatesMethod m = {
                offset:  maxUpdateId,
                limit:   limit,
                timeout: timeout,
            };

            return callMethod!(Update[], GetUpdatesMethod)(m);
        }

        User getMe()
        {
            GetMeMethod m = {
                httpMethod : HTTPMethod.GET
            };

            return callMethod!(User, GetMeMethod)(m);
        }

        Message sendMessage(string chatId, string text)
        {
            SendMessageMethod m = {
                chat_id    : chatId,
                text       : text,
            };

            return callMethod!(Message, SendMessageMethod)(m);
        }

        Message sendMessage(long chatId, string text)
        {
            return sendMessage(chatId.to!string, text);
        }

        Message sendMessage(ref SendMessageMethod m)
        {
            return callMethod!(Message, SendMessageMethod)(m);
        }
}
