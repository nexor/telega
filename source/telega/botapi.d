module telega.botapi;

import vibe.http.client;
import vibe.stream.operations;
import vibe.core.core;
import vibe.core.log;
import asdf;
import std.conv;
import std.typecons;
import std.exception;
import std.traits;

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

enum isTelegramId(T) = isSomeString!T || isIntegral!T;

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
    Nullable!User        forward_from;
    Nullable!Chat        forward_from_chat;
    uint                 forward_from_message_id;
    string               forward_signature;
    uint                 forward_date;
    Nullable!ReplyToMessage reply_to_message;
    uint                 edit_date;
    string               media_group_id;
    string               author_signature;
    string               text;
    Nullable!MessageEntity[] entities;
    Nullable!MessageEntity[] caption_entities;
    Nullable!Audio           audio;
    Nullable!Document        document;
    Nullable!PhotoSize[]     photo;
    Nullable!Sticker         sticker;
    Nullable!Video           video;
    Nullable!Voice           voice;
    Nullable!VideoNote       video_note;
    string              caption;
    Nullable!Contact         contact;
    Nullable!Location        location;
    Nullable!Venue           venue;
    Nullable!User[]          new_chat_members;
    Nullable!User            left_chat_member;
    string              new_chat_title;
    Nullable!PhotoSize[]     new_chat_photo;
    bool                delete_chat_photo;
    bool                group_chat_created;
    bool                supergroup_chat_created;
    bool                channel_chat_created;
    long                migrate_to_chat_id;
    long                migrate_from_chat_id;
    // TODO Nullable!Message         pinned_message;
    // TODO Nullable!Invoice         invoice;
    // TODO Nullable!SuccessfulPayment successful_payment;
    string              connected_website;

    @property
    uint id()
    {
        return message_id;
    }
}

struct ReplyToMessage
{
    uint                 message_id;
    uint                 date;
    Chat                 chat;
    Nullable!User        from;
    Nullable!User        forward_from;
    Nullable!Chat        forward_from_chat;
    uint                 forward_from_message_id;
    string               forward_signature;
    uint                 forward_date;
    uint                 edit_date;
    string               media_group_id;
    string               author_signature;
    string               text;
    Nullable!MessageEntity[] entities;
    Nullable!MessageEntity[] caption_entities;
    Nullable!Audio           audio;
    Nullable!Document        document;
    Nullable!PhotoSize[]     photo;
    Nullable!Sticker         sticker;
    Nullable!Video           video;
    Nullable!Voice           voice;
    Nullable!VideoNote       video_note;
    string              caption;
    Nullable!Contact         contact;
    Nullable!Location        location;
    Nullable!Venue           venue;
    Nullable!User[]          new_chat_members;
    Nullable!User            left_chat_member;
    string              new_chat_title;
    Nullable!PhotoSize[]     new_chat_photo;
    bool                delete_chat_photo;
    bool                group_chat_created;
    bool                supergroup_chat_created;
    bool                channel_chat_created;
    long                migrate_to_chat_id;
    long                migrate_from_chat_id;
    // TODO Nullable!Message         pinned_message;
    // TODO Nullable!Invoice         invoice;
    // TODO Nullable!SuccessfulPayment successful_payment;
    string              connected_website;

    @property
    uint id()
    {
        return message_id;
    }
}

struct Update
{
    uint             update_id;
    Nullable!Message message;

    Nullable!Message edited_message;
    Nullable!Message channel_post;
    Nullable!Message edited_channel_post;

    @property
    uint id()
    {
        return update_id;
    }
}

struct WebhookInfo
{
    string   url;
    bool     has_custom_certificate;
    uint     pending_update_count;
    uint     last_error_date;
    string   last_error_message;
    uint     max_connections;
    string[] allowed_updates;
}

enum ParseMode
{
    Markdown = "Markdown",
    HTML     = "HTML",
    None     = "",
}

struct MessageEntity
{
    string        type;
    uint          offset;
    uint          length;
    string        url;
    Nullable!User user;
}

struct PhotoSize
{
    string        file_id;
    int           width;
    int           height;

    Nullable!uint file_size;
}

struct Audio
{
    string file_id;
    uint   duration;
    string performer;
    string title;
    string mime_type;
    uint   file_size;
}

struct Document
{
    string    file_id;
    PhotoSize thumb;
    string    file_name;
    string    mime_type;
    uint      file_size;
}

struct Video
{
    string file_id;
    uint width;
    uint height;
    uint duration;
    PhotoSize thumb;
    string mime_type;
    uint file_size;
}

struct Voice
{
    string file_id;
    uint   duration;
    string mime_type;
    uint   file_size;
}

struct VideoNote
{
    string    file_id;
    uint      length;
    uint      duration;
    PhotoSize thumb;
    uint      file_size;
}

struct Contact
{
    string phone_number;
    string first_name;
    string last_name;
    string user_id;
}

struct Location
{
    float longitude;
    float latitude;
}

struct Venue
{
    Location location;
    string   title;
    string   address;
    string   foursquare_id;
}

struct UserProfilePhotos
{
    uint          total_count;
    PhotoSize[][] photos;
}

struct File
{
    string file_id;
    uint   file_size;
    string file_path;
}

import std.variant;
import vibe.data.json : Json;

alias ReplyMarkupAlgebraic =
    Algebraic!(ReplyKeyboardMarkup, ReplyKeyboardRemove, InlineKeyboardMarkup, ForceReply);
enum isReplyMarkup(T) =
    is(T == ReplyKeyboardMarkup) || is(T == ReplyKeyboardRemove) ||
    is(T == InlineKeyboardMarkup) || is(T == ForceReply);

/**
 Abstract structure for unioining ReplyKeyboardMarkup, ReplyKeyboardRemove,
 InlineKeyboardMarkup and ForceReply
*/
struct ReplyMarkup
{
    ReplyMarkupAlgebraic replyMarkup;

    void opAssign(T)(T markup)
        if (isReplyMarkup!T)
    {
        replyMarkup = markup;
    }

    @safe
    Json toJson() const
    {
        if (!replyMarkup.hasValue) {
            return Json(null);
        }

        return getJson();
    }

    // this method should not be used
    @safe
    ReplyMarkup fromJson(Json src)
    {
        return ReplyMarkup.init;
    }

    @trusted
    protected Json getJson() const
    {
        import vibe.data.json : serializeToJson;

        if (replyMarkup.type == typeid(ReplyKeyboardMarkup)) {
            ReplyKeyboardMarkup reply = cast(ReplyKeyboardMarkup)replyMarkup.get!ReplyKeyboardMarkup;

            return reply.serializeToJson();
        } else if (replyMarkup.type == typeid(ReplyKeyboardRemove)) {
            ReplyKeyboardRemove reply = cast(ReplyKeyboardRemove)replyMarkup.get!ReplyKeyboardRemove;

            return reply.serializeToJson();
        } else if (replyMarkup.type == typeid(InlineKeyboardMarkup)) {
            InlineKeyboardMarkup reply = cast(InlineKeyboardMarkup)replyMarkup.get!InlineKeyboardMarkup;

            return reply.serializeToJson();
        } else if (replyMarkup.type == typeid(ForceReply)) {
            ForceReply reply = cast(ForceReply)replyMarkup.get!ForceReply;

            return reply.serializeToJson();
        }

        return Json(null);
    }
}

struct ReplyKeyboardMarkup
{
    KeyboardButton[][] keyboard;
    bool               resize_keyboard;
    bool               one_time_keyboard;
    bool               selective;

    this (string[][] keyboard)
    {
        foreach (ref row; keyboard) {
            KeyboardButton[] buttonRow;

            foreach (ref item; row) {
                buttonRow ~= KeyboardButton(item);
            }
            this.keyboard ~= buttonRow;
        }
    }
}

struct KeyboardButton
{
    string text;
    bool   request_contact;
    bool   request_location;
}

struct ReplyKeyboardRemove
{
    immutable bool remove_keyboard = true;
    bool           selective;
}

struct InlineKeyboardMarkup
{
    InlineKeyboardButton[][] inline_keyboard;
}

struct InlineKeyboardButton
{
    string       text;
    string       url;
    string       callback_data;
    string       switch_inline_query;
    string       switch_inline_query_current_chat;
    bool         pay;
}

struct ForceReply
{
    const bool     force_reply = true;
    bool           selective;
}

struct ChatPhoto
{
    string small_file_id;
    string big_file_id;
}

struct ChatMember
{
    User   user;
    string status;
    uint   until_date;
    bool   can_be_edited;
    bool   can_change_info;
    bool   can_post_messages;
    bool   can_edit_messages;
    bool   can_delete_messages;
    bool   can_invite_users;
    bool   can_restrict_members;
    bool   can_pin_messages;
    bool   can_promote_members;
    bool   can_send_messages;
    bool   can_send_media_messages;
    bool   can_send_other_messages;
    bool   can_add_web_page_previews;
}

struct ResponseParameters
{
    long migrate_to_chat_id;
    uint retry_after;
}

struct InputMediaPhoto
{
    string type;
    string media;
    string caption;
    string parse_mode;
}

struct InputMediaVideo
{
    string type;
    string media;
    string caption;
    string parse_mode;
    uint   width;
    uint   height;
    uint   duration;
    bool   supports_streaming;
}

struct InputFile
{

}

struct Sticker
{
    string       file_id;
    uint         width;
    uint         height;
    PhotoSize    thumb;
    string       emoji;
    string       set_name;
    MaskPosition mask_position;
    uint         file_size;
}

struct StickerSet
{
    string    name;
    string    title;
    bool      contains_masks;
    Sticker[] stickers;
}

struct MaskPosition
{
    string point;
    float  x_shift;
    float  y_shift;
    float  scale;
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

    ReplyMarkup reply_markup;
}

struct ForwardMessageMethod
{
    mixin TelegramMethod;

    package
    string name = "/forwardMessage";

    string chat_id;
    string from_chat_id;
    bool   disable_notification;
    uint   message_id;
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
            import vibe.data.json : serializeToJsonString;

            T result;

            logDiagnostic("[%d] Requesting %s", requestCounter, method.name);

            requestHTTP(apiUrl ~ method.name,
                (scope req) {
                    req.method = method.httpMethod;
                    if (method.httpMethod == HTTPMethod.POST) {
                        logDebugV("[%d] Sending body:\n  %s", requestCounter, method.serializeToJsonString());
                        req.headers["Content-Type"] = "application/json";
                        req.writeBody( cast(const(ubyte[])) serializeToJsonString(method) );
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

        Message sendMessage(T)(T chatId, string text)
            if (isTelegramId!T)
        {
            SendMessageMethod m = {
                text       : text,
            };

            static if (isIntegral!T) {
                m.chat_id = chatId.to!string;
            } else {
                m.chat_id = chatId;
            }

            return sendMessage(m);
        }

        Message sendMessage(ref SendMessageMethod m)
        {
            return callMethod!(Message, SendMessageMethod)(m);
        }

        Message forwardMessage(T1, T2)(T1 chatId, T2 fromChatId, uint messageId)
            if (isTelegramId!T1 && isTelegramId!T2)
        {
            ForwardMessageMethod m = {
                message_id : messageId
            };

            static if (isIntegral!T1) {
                m.chat_id = chatId.to!string;
            } else {
                m.chat_id = chatId;
            }

            static if (isIntegral!T2) {
                m.from_chat_id = fromChatId.to!string;
            } else {
                m.from_chat_id = fromChatId;
            }

            return callMethod!(Message, ForwardMessageMethod)(m);
        }

        Message forwardMessage(ref ForwardMessageMethod m)
        {
            return callMethod!(Message, ForwardMessageMethod)(m);
        }
}
