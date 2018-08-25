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

struct JsonableAlgebraic(Typelist ...)
{
    import std.meta;
    import std.variant;
    import vibe.data.json : Json;

    private Algebraic!Typelist types;

    // TODO implement copy constructor from Typelist types

    void opAssign(T)(T value)
        if (staticIndexOf!(T, Typelist) >= 0)
    {
        types = value;
    }

    @safe
    Json toJson() const
    {
        if (!types.hasValue) {
            return Json.emptyObject;
        }

        return getJson();
    }

    // this method should not be used
    @safe
    typeof(this) fromJson(Json src)
    {
        return typeof(this).init;
    }

    @trusted
    protected Json getJson() const
    {
        import vibe.data.json : serializeToJson;

        static foreach (T; Typelist) {
            if (types.type == typeid(T)) {
                T reply = cast(T)types.get!T;

                return reply.serializeToJson();
            }
        }

        return Json(null);
    }
}

unittest
{
    import vibe.data.json;

    struct S1
    {
        int s1;
    }

    struct S2
    {
        string s2;
    }

    JsonableAlgebraic!(S1, S2) jsonable;

    struct JsonableAggregate
    {
        JsonableAlgebraic!(S1, S2) aggr;
    }

    jsonable = S1(42);
    assert(`{"s1":42}` == jsonable.serializeToJsonString());

    jsonable = S2("s2 value");
    assert(`{"s2":"s2 value"}` == jsonable.serializeToJsonString());

    JsonableAggregate jaggr;
    jaggr.aggr = jsonable;
    assert(`{"aggr":{"s2":"s2 value"}}` == jaggr.serializeToJsonString());
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
    Nullable!Game            game;
    Nullable!PhotoSize[]     photo;
    Nullable!Sticker         sticker;
    Nullable!Video           video;
    Nullable!Voice           voice;
    Nullable!VideoNote       video_note;
    // TODO Nullable!Message reply_to_message;
    // TODO Nullable!Message pinned_message;
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
    Nullable!Invoice         invoice;
    Nullable!SuccessfulPayment successful_payment;
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
    Nullable!InlineQuery        inline_query;
    Nullable!ChosenInlineResult chosen_inline_result;
    Nullable!CallbackQuery      callback_query;
    Nullable!ShippingQuery      shipping_query;
    Nullable!PreCheckoutQuery   pre_checkout_query;

    @property
    uint id()
    {
        return update_id;
    }
}

unittest
{
    string json = `{
        "update_id": 143,
        "message": {
            "message_id": 243,
            "text": "message text"
        }
    }`;

    Update u = deserialize!Update(json);

    assert(u.id == 143);
    assert(u.message.message_id == 243);
    assert(u.message.text == "message text");
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

import std.meta : AliasSeq, staticIndexOf;
import std.variant : Algebraic;

alias ReplyMarkupStructs = AliasSeq!(ReplyKeyboardMarkup, ReplyKeyboardRemove, InlineKeyboardMarkup, ForceReply);

/**
 Abstract structure for unioining ReplyKeyboardMarkup, ReplyKeyboardRemove,
 InlineKeyboardMarkup and ForceReply
*/
alias ReplyMarkup = JsonableAlgebraic!ReplyMarkupStructs;
enum isReplyMarkup(T) =
    is(T == ReplyMarkup) || staticIndexOf!(T, ReplyMarkupStructs) >= 0;

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
    bool remove_keyboard = true;
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
    CallbackGame callback_game;
    bool         pay;
}

struct CallbackQuery
{
    string           id;
    User             from;
    Nullable!Message message;
    string           inline_message_id;
    string           chat_instance;
    string           data;
    string           game_short_name;
}

struct ForceReply
{
    bool     force_reply = true;
    bool     selective;
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

alias InputMediaStructs = AliasSeq!(InputMediaPhoto, InputMediaVideo);

alias InputMedia = JsonableAlgebraic!InputMediaStructs;

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
    // no fields
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


/*** Inline mode types ***/

struct InlineQuery
{
    string id;
    User from;
    Nullable!Location location;
    string query;
    string offset;
}

alias InlineQueryResultStructs = AliasSeq!(
    InlineQueryResultArticle, InlineQueryResultPhoto, InlineQueryResultGif, InlineQueryResultMpeg4Gif,
    InlineQueryResultVideo, InlineQueryResultAudio, InlineQueryResultVoice, InlineQueryResultDocument,
    InlineQueryResultLocation, InlineQueryResultVenue, InlineQueryResultContact, InlineQueryResultGame,
    InlineQueryResultCachedPhoto, InlineQueryResultCachedGif, InlineQueryResultCachedMpeg4Gif,
    InlineQueryResultCachedSticker, InlineQueryResultCachedDocument, InlineQueryResultCachedVideo,
    InlineQueryResultCachedVoice, InlineQueryResultCachedAudio
);

alias InlineQueryResult = JsonableAlgebraic!InlineQueryResultStructs;

mixin template InlineQueryFields()
{
    Nullable!InlineKeyboardMarkup reply_markup;
    Nullable!InputMessageContent  input_message_content;
}

struct InlineQueryResultArticle
{
    string type = "article";
    string id;
    string title;
    string url;
    bool hide_url;
    string description;
    string thumb_url;
    uint thumb_width;
    uint thumb_height;

    mixin InlineQueryFields;
}

struct InlineQueryResultPhoto
{
    string type = "photo";
    string id;
    string photo_url;
    string thumb_url;
    uint photo_width;
    uint photo_height;
    string title;
    string description;
    string caption;
    ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultGif
{
    string type = "gif";
    string id;
    string gif_url;
    uint gif_width;
    uint gif_height;
    uint gif_duration;
    string thumb_url;
    string title;
    string caption;
    ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultMpeg4Gif
{
    string type ="mpeg4_gif";
    string id;
    string mpeg4_url;
    uint mpeg4_width;
    uint mpeg4_height;
    uint mpeg4_duration;
    string thumb_url;
    string title;
    string caption;
    ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultVideo
{
    string type ="video";
    string id;
    string video_url;
    string mime_type;
    string thumb_url;
    string title;
    string caption;
    ParseMode parse_mode;
    uint video_width;
    uint video_height;
    uint video_duration;
    string description;

    mixin InlineQueryFields;
}

struct InlineQueryResultAudio
{
    string type = "audio";
    string    id;
    string    audio_url;
    string    title;
    string    caption;
    ParseMode parse_mode;
    string    performer;
    uint      audio_duration;

    mixin InlineQueryFields;
}

struct InlineQueryResultVoice
{
    string type = "voice";
    string    id;
    string    voice_url;
    string    title;
    string    caption;
    ParseMode parse_mode;
    uint      voice_duration;

    mixin InlineQueryFields;
}

struct InlineQueryResultDocument
{
    string type = "document";
    string    id;
    string    title;
    string    caption;
    ParseMode parse_mode;
    string    document_url;
    string    mime_type;
    string    description;
    string    thumb_url;
    uint      thumb_width;
    uint      thumb_height;

    mixin InlineQueryFields;
}

struct InlineQueryResultLocation
{
    string type = "location";
    string id;
    float latitude;
    float longitude;
    string title;
    uint live_period;
    string thumb_url;
    uint thumb_width;
    uint thumb_height;

    mixin InlineQueryFields;
}

struct InlineQueryResultVenue
{
    string type = "venue";
    string id;
    float latitude;
    float longitude;
    string title;
    string address;
    string foursquare_id;
    string thumb_url;
    uint thumb_width;
    uint thumb_height;

    mixin InlineQueryFields;
}

struct InlineQueryResultContact
{
    string type = "contact";
    string id;
    string phone_number;
    string first_name;
    string last_name;
    string thumb_url;
    uint thumb_width;
    uint thumb_height;

    mixin InlineQueryFields;
}

struct InlineQueryResultGame
{
    string type = "game";
    string id;
    string game_short_name;
    Nullable!InlineKeyboardMarkup reply_markup;
}


struct InlineQueryResultCachedPhoto
{
    string type = "photo";
    string id;
    string photo_file_id;
    string title;
    string description;
    string caption;
    ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedGif
{
    string type = "gif";
    string id;
    string gif_file_id;
    string title;
    string caption;
    ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedMpeg4Gif
{
    string type = "mpeg4_gif";
    string id;
    string mpeg4_file_id;
    string title;
    string caption;
    ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedSticker
{
    string type = "sticker";
    string id;
    string sticker_file_id;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedDocument
{
    string type = "document";
    string    id;
    string    title;
    string    document_file_id;
    string    description;
    string    caption;
    ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedVideo
{
    string type = "video";
    string    id;
    string    video_file_id;
    string    title;
    string    description;
    string    caption;
    ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedVoice
{
    string type = "voice";
    string    id;
    string    voice_file_id;
    string    title;
    string    caption;
    ParseMode parse_mode;

    mixin InlineQueryFields;
}


struct InlineQueryResultCachedAudio
{
    string type = "audio";
    string    id;
    string    audio_file_id;
    string    caption;
    ParseMode parse_mode;

    mixin InlineQueryFields;
}

alias InputMessageContentStructs = AliasSeq!(
    InputTextMessageContent, InputLocationMessageContent, InputVenueMessageContent, InputContactMessageContent
);

alias InputMessageContent = JsonableAlgebraic!InputMessageContentStructs;

struct InputTextMessageContent
{
    string message_text;
    string parse_mode;
    bool   disable_web_page_preview;
}

struct InputLocationMessageContent
{
    float latitude;
    float longitude;
    uint  live_period;
}

struct InputVenueMessageContent
{
    float  latitude;
    float  longitude;
    string title;
    string address;
    string foursquare_id;
}

struct InputContactMessageContent
{
    string phone_number;
    string first_name;
    string last_name;
}

struct ChosenInlineResult
{
    string   result_id;
    User     from;
    Nullable!Location location;
    string   inline_message_id;
    string   query;
}

/*** Payments types ***/
struct LabeledPrice
{
    string label;
    uint   amount;
}

struct Invoice
{
    string title;
    string description;
    string start_parameter;
    string currency;
    uint   total_amount;
}

struct ShippingAddress
{
    string country_code;
    string state;
    string city;
    string street_line1;
    string street_line2;
    string post_code;
}

struct OrderInfo
{
    string name;
    string phone_number;
    string email;
    Nullable!ShippingAddress shipping_address;
}

struct ShippingOption
{
    string id;
    string title;
    LabeledPrice[] prices;
}
struct SuccessfulPayment
{
    string currency;
    uint   total_amount;
    string invoice_payload;
    string shipping_option_id;
    Nullable!OrderInfo order_info;
    string telegram_payment_charge_id;
    string provider_payment_charge_id;
}

struct ShippingQuery
{
    string id;
    User   from;
    string invoice_payload;
    ShippingAddress shipping_address;
}

struct PreCheckoutQuery
{
    string             id;
    User               from;
    string             currency;
    uint               total_amount;
    string             invoice_payload;
    string             shipping_option_id;
    Nullable!OrderInfo order_info;
}

/*** Games types ***/

struct Game
{
    string        title;
    string        description;
    PhotoSize[]   photo;
    string        text;
    MessageEntity text_entities;
    Animation     animation;
}

struct Animation
{
    string    file_id;
    PhotoSize thumb;
    string    file_name;
    string    mime_type;
    uint      file_size;
}

struct CallbackGame
{
    // no fields
}

struct GameHighScore
{
    uint  position;
    User  user;
    uint  score;
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
        uint _maxUpdateId = 1;

        struct MethodResult(T)
        {
            bool   ok;
            T      result;
            ushort error_code;
            string description;
        }

    public:
        this(string token, string baseUrl = BaseApiUrl)
        {
            this.baseUrl = baseUrl;
            this.apiUrl = baseUrl ~ token;
        }

        @property
        uint maxUpdateId()
        {
            return _maxUpdateId;
        }

        void updateProcessed(int updateId)
        {
            if (updateId >= _maxUpdateId) {
                _maxUpdateId = updateId + 1;
            }
        }

        void updateProcessed(ref Update update)
        {
            updateProcessed(update.id);
        }

        T callMethod(T, M)(ref M method)
        {
            import vibe.data.json : serializeToJsonString;

            T result;

            logDiagnostic("[%d] Requesting %s", requestCounter, method._path);

            version(unittest)
            {
                import std.stdio;
                serializeToJsonString(method).writeln();
            } else {
                requestHTTP(apiUrl ~ method._path,
                    (scope req) {
                        req.method = method._httpMethod;
                        if (method._httpMethod == HTTPMethod.POST) {
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
            }

            return result;
        }

        unittest
        {
            auto api = new BotApi("http://server", "botToken");

            assert(api.maxUpdateId == 1);

            api.updateProcessed(2);

            assert(api.maxUpdateId == 3);

            Update update = {
                update_id: 3
            };

            api.updateProcessed(update);

            assert(api.maxUpdateId == 4);
        }
}
