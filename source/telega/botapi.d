module telega.botapi;

import vibe.http.client : HTTPMethod;
import vibe.core.core;
import vibe.core.log;
import asdf;
import std.conv;
import std.typecons;
import std.exception;
import std.traits;
import telega.http;
import telega.serialization;

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

    Nullable!string last_name;
    Nullable!string username;
    Nullable!string language_code;
}

unittest
{
    string json = `{
        "id": 42,
        "is_bot": false,
        "first_name": "FirstName"
    }`;

    User u = deserialize!User(json);

    assert(u.last_name.isNull);
}

unittest
{
    string json = `{
        "id": 42,
        "is_bot": false,
        "first_name": "FirstName",
        "last_name": "LastName"
    }`;

    User u = deserialize!User(json);

    assert(false == u.last_name.isNull);
}



@serializedAs!ChatTypeProxy
enum ChatType : string
{
    Private    = "private",
    Group      = "group",
    Supergroup = "supergroup",
    Channel    = "channel"
}

struct ChatTypeProxy
{
    ChatType t;

    this(ChatType type)
    {
        t = type;
    }

    ChatType opCast(T : ChatType)()
    {
        return t;
    }

    static ChatTypeProxy deserialize(Asdf v)
    {
        return ChatTypeProxy(cast(ChatType)cast(string)v);
    }
}

struct Chat
{
    long id;
    ChatType type;
    Nullable!string title;
    Nullable!string first_name;
    Nullable!string last_name;
    Nullable!string username;
    Nullable!bool all_members_are_administrators;
    Nullable!ChatPhoto photo;
    Nullable!string description;
    Nullable!string invite_link;
    // TODO Nullable!Message pinned_message;
    Nullable!string sticker_set_name;
    Nullable!bool can_set_sticker_set;
}

unittest
{
    string json = `{
        "id": 42,
        "type": "group",
        "title": "chat title"
    }`;

    Chat c = deserialize!Chat(json);

    assert(c.id == 42);
    assert(c.type == ChatType.Group);
}

struct Message
{
    uint                 message_id;
    uint                 date;
    Chat                 chat;
    Nullable!User        from;
    Nullable!User        forward_from;
    Nullable!Chat        forward_from_chat;
    Nullable!uint        forward_from_message_id;
    Nullable!string      forward_signature;
    Nullable!uint        forward_date;
    Nullable!uint        edit_date;
    Nullable!string      media_group_id;
    Nullable!string      author_signature;
    Nullable!string      text;
    Nullable!MessageEntity[] entities;
    Nullable!MessageEntity[] caption_entities;
    Nullable!Audio           audio;
    Nullable!Document        document;
    Nullable!Animation       animation;
    Nullable!Game            game;
    Nullable!PhotoSize[]     photo;
    Nullable!Sticker         sticker;
    Nullable!Video           video;
    Nullable!Voice           voice;
    Nullable!VideoNote       video_note;
    // TODO Nullable!Message reply_to_message;
    // TODO Nullable!Message pinned_message;
    Nullable!string          caption;
    Nullable!Contact         contact;
    Nullable!Location        location;
    Nullable!Venue           venue;
    Nullable!User[]          new_chat_members;
    Nullable!User            left_chat_member;
    Nullable!string          new_chat_title;
    Nullable!PhotoSize[]     new_chat_photo;
    Nullable!bool            delete_chat_photo;
    Nullable!bool            group_chat_created;
    Nullable!bool            supergroup_chat_created;
    Nullable!bool            channel_chat_created;
    Nullable!long            migrate_to_chat_id;
    Nullable!long            migrate_from_chat_id;
    Nullable!Invoice         invoice;
    Nullable!SuccessfulPayment successful_payment;
    Nullable!string              connected_website;

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
    Nullable!uint     last_error_date;
    Nullable!string   last_error_message;
    Nullable!uint     max_connections;
    Nullable!string[] allowed_updates;
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
    Nullable!string  url;
    Nullable!User    user;
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
    Nullable!string performer;
    Nullable!string title;
    Nullable!string mime_type;
    Nullable!uint   file_size;
    Nullable!PhotoSize thumb;
}

// TODO Add Nullable fields
struct Document
{
    string    file_id;
    PhotoSize thumb;
    string    file_name;
    string    mime_type;
    uint      file_size;
}

// TODO Add Nullable fields
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

// TODO Add Nullable fields
struct Voice
{
    string file_id;
    uint   duration;
    string mime_type;
    uint   file_size;
}

// TODO Add Nullable fields
struct VideoNote
{
    string    file_id;
    uint      length;
    uint      duration;
    PhotoSize thumb;
    uint      file_size;
}

// TODO Add Nullable fields
struct Contact
{
    string phone_number;
    string first_name;
    string last_name;
    string user_id;
}

// TODO Add Nullable fields
struct Location
{
    float longitude;
    float latitude;
}

// TODO Add Nullable fields
struct Venue
{
    Location location;
    string   title;
    string   address;
    string   foursquare_id;
}

// TODO Add Nullable fields
struct UserProfilePhotos
{
    uint          total_count;
    PhotoSize[][] photos;
}

// TODO Add Nullable fields
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

alias ReplyMarkup = JsonableAlgebraicProxy!ReplyMarkupStructs;
enum isReplyMarkup(T) =
    is(T == ReplyMarkup) || staticIndexOf!(T, ReplyMarkupStructs) >= 0;

import std.algorithm.iteration;
import std.array;

static bool falseIfNull(Nullable!bool value)
{
    if (value.isNull) {
        return false;
    }

    return cast(bool)value;
}

static bool trueIfNull(Nullable!bool value)
{
    if (value.isNull) {
        return true;
    }

    return cast(bool)value;
}

struct ReplyKeyboardMarkup
{
    KeyboardButton[][] keyboard;

 // TODO   @serializationTransformOut!falseIfNull
    Nullable!bool      resize_keyboard = false;

// TODO     @serializationTransformOut!falseIfNull
    Nullable!bool      one_time_keyboard = false;

// TODO    @serializationTransformOut!falseIfNull
    Nullable!bool      selective = false;

    this (string[][] keyboard)
    {
        this.keyboard = keyboard.map!toKeyboardButtonRow.array;
    }

    void opOpAssign(string op : "~")(KeyboardButton[] buttons)
    {
        keyboard ~= buttons;
    }
}

struct KeyboardButton
{
    string text;

    Nullable!bool   request_contact;
    Nullable!bool   request_location;

    this(string text, bool requestContact = false, bool requestLocation = false)
    {
        this.text = text;
        this.request_contact = requestContact;
        this.request_location = requestLocation;
    }
}

KeyboardButton[] toKeyboardButtonRow(string[] row)
{
    return row.map!(b => KeyboardButton(b)).array;
}

struct ReplyKeyboardRemove
{
    bool remove_keyboard = true;
    Nullable!bool           selective = false;
}

struct InlineKeyboardMarkup
{
    InlineKeyboardButton[][] inline_keyboard;
}

struct InlineKeyboardButton
{
    string       text;
    Nullable!string       url;
    Nullable!string       callback_data;
    Nullable!string       switch_inline_query;
    Nullable!string       switch_inline_query_current_chat;
    Nullable!CallbackGame callback_game;
    Nullable!bool         pay;
}

// TODO Add Nullable fields
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
    Nullable!bool     selective;
}

struct ChatPhoto
{
    string small_file_id;
    string big_file_id;
}

// TODO Add Nullable fields
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

// TODO Add Nullable fields
struct ResponseParameters
{
    long migrate_to_chat_id;
    uint retry_after;
}

alias InputMediaStructs = AliasSeq!(InputMediaPhoto, InputMediaVideo);

alias InputMedia = JsonableAlgebraicProxy!InputMediaStructs;

struct InputMediaPhoto
{
    string type;
    string media;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;
}

struct InputMediaVideo
{
    string type;
    string media;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;
    Nullable!uint   width;
    Nullable!uint   height;
    Nullable!uint   duration;
    Nullable!bool   supports_streaming;
}

// TODO InputMediaAnimation
// TODO InputMediaAudio
// TODO InputMediaDocument

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

alias InlineQueryResult = JsonableAlgebraicProxy!InlineQueryResultStructs;

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
    Nullable!string url;
    Nullable!bool hide_url;
    Nullable!string description;
    Nullable!string thumb_url;
    Nullable!uint thumb_width;
    Nullable!uint thumb_height;

    Nullable!InlineKeyboardMarkup reply_markup;
    InputMessageContent  input_message_content; // can't be nullable
}

struct InlineQueryResultPhoto
{
    string type = "photo";
    string id;
    string photo_url;
    string thumb_url;
    Nullable!uint photo_width;
    Nullable!uint photo_height;
    Nullable!string title;
    Nullable!string description;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultGif
{
    string type = "gif";
    string id;
    string gif_url;
    Nullable!uint gif_width;
    Nullable!uint gif_height;
    Nullable!uint gif_duration;
    Nullable!string thumb_url;
    Nullable!string title;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultMpeg4Gif
{
    string type ="mpeg4_gif";
    string id;
    string mpeg4_url;
    Nullable!uint mpeg4_width;
    Nullable!uint mpeg4_height;
    Nullable!uint mpeg4_duration;
    Nullable!string thumb_url;
    Nullable!string title;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;

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
    Nullable!string caption;
    Nullable!ParseMode parse_mode;
    Nullable!uint video_width;
    Nullable!uint video_height;
    Nullable!uint video_duration;
    Nullable!string description;

    mixin InlineQueryFields;
}

struct InlineQueryResultAudio
{
    string    type = "audio";
    string    id;
    string    audio_url;
    string    title;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;
    Nullable!string    performer;
    Nullable!uint      audio_duration;

    mixin InlineQueryFields;
}

struct InlineQueryResultVoice
{
    string    type = "voice";
    string    id;
    string    voice_url;
    string    title;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;
    Nullable!uint      voice_duration;

    mixin InlineQueryFields;
}

struct InlineQueryResultDocument
{
    string    type = "document";
    string    id;
    string    title;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;
    Nullable!string    document_url;
    Nullable!string    mime_type;
    Nullable!string    description;
    Nullable!string    thumb_url;
    Nullable!uint      thumb_width;
    Nullable!uint      thumb_height;

    mixin InlineQueryFields;
}

struct InlineQueryResultLocation
{
    string type = "location";
    string id;
    float latitude;
    float longitude;
    string title;
    Nullable!uint live_period;
    Nullable!string thumb_url;
    Nullable!uint thumb_width;
    Nullable!uint thumb_height;

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
    Nullable!string foursquare_id;
    Nullable!string thumb_url;
    Nullable!uint thumb_width;
    Nullable!uint thumb_height;

    mixin InlineQueryFields;
}

struct InlineQueryResultContact
{
    string type = "contact";
    string id;
    string phone_number;
    string first_name;
    Nullable!string last_name;
    Nullable!string thumb_url;
    Nullable!uint thumb_width;
    Nullable!uint thumb_height;

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
    Nullable!string title;
    Nullable!string description;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedGif
{
    string type = "gif";
    string id;
    string gif_file_id;
    Nullable!string title;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedMpeg4Gif
{
    string type = "mpeg4_gif";
    string id;
    string mpeg4_file_id;
    Nullable!string title;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;

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
    Nullable!string    description;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedVideo
{
    string type = "video";
    string    id;
    string    video_file_id;
    string    title;
    Nullable!string    description;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedVoice
{
    string type = "voice";
    string    id;
    string    voice_file_id;
    string    title;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}


struct InlineQueryResultCachedAudio
{
    string type = "audio";
    string    id;
    string    audio_file_id;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

alias InputMessageContentStructs = AliasSeq!(
    InputTextMessageContent, InputLocationMessageContent, InputVenueMessageContent, InputContactMessageContent
);

alias InputMessageContent = JsonableAlgebraicProxy!InputMessageContentStructs;

struct InputTextMessageContent
{
    string message_text;
    Nullable!ParseMode parse_mode;
    Nullable!bool   disable_web_page_preview;
}

struct InputLocationMessageContent
{
    float latitude;
    float longitude;
    Nullable!uint  live_period;
}

struct InputVenueMessageContent
{
    float  latitude;
    float  longitude;
    string title;
    string address;
    Nullable!string foursquare_id;
    // TODO new field Nullable!string foursquare_type;
}

struct InputContactMessageContent
{
    string phone_number;
    string first_name;
    Nullable!string last_name;
    // TODO new field Nullable!string vcard;
}

struct ChosenInlineResult
{
    string   result_id;
    User     from;
    Nullable!Location location;
    Nullable!string   inline_message_id;
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

// TODO add nullable fields
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

// TODO add nullable fields
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

// TODO add nullable fields
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

/*** Telegram Passport ***/
// TODO

/*** Games types ***/

// TODO add nullable fields
struct Game
{
    string        title;
    string        description;
    PhotoSize[]   photo;
    string        text;
    MessageEntity text_entities;
    Animation     animation;
}

// TODO add nullable fields and a new fields
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
            T result;

            logDiagnostic("[%d] Requesting %s", requestCounter, method._path);

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
