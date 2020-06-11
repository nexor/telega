module telega.botapi;

import vibe.core.log;
import asdf : Asdf, serializedAs;
import asdf.serialization : deserialize;
import std.typecons : Nullable;
import std.exception : enforce;
import std.traits : isSomeString, isIntegral;
import telega.http : HttpClient;
import telega.serialization : serializeToJsonString, JsonableAlgebraicProxy;
import telega.telegram.games : Game, Animation, CallbackGame;

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
    assert(chatId.isString() == false);

    chatId = "@chat";
    assert(chatId.isString() == true);

    string chatIdString = chatId;
    assert(chatIdString == "@chat");

    long chatIdNum = cast(long)chatId;
    assert(chatIdNum == 0);

    chatId = 42;

    chatIdNum = cast(long)chatId;
    assert(chatIdNum == 42);

    string chatIdFunc(ChatId id)
    {
        return id;
    }

    assert(chatIdFunc(cast(ChatId)"abc") == "abc");
    assert(chatIdFunc(cast(ChatId)45) == "45");
}


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

enum isTelegramId(T) = isSomeString!T || isIntegral!T || is(T == ChatId);

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
        "title": "chat title",
        "all_members_are_administrators": false
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

    @property @safe @nogc nothrow pure
    uint id()
    {
        return update_id;
    }
}

@safe @nogc nothrow pure
bool isMessageType(in Update update)
{
    return !update.message.isNull;
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
    assert(u.message.text.get == "message text");
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

alias ReplyMarkupStructs = AliasSeq!(
    ReplyKeyboardMarkup,
    ReplyKeyboardRemove,
    InlineKeyboardMarkup,
    ForceReply
    );

/**
 Abstract structure for unioining ReplyKeyboardMarkup, ReplyKeyboardRemove,
 InlineKeyboardMarkup and ForceReply
*/

alias ReplyMarkup = JsonableAlgebraicProxy!ReplyMarkupStructs;
enum isReplyMarkup(T) =
    is(T == ReplyMarkup) || staticIndexOf!(T, ReplyMarkupStructs) >= 0;

import std.algorithm.iteration;
import std.array;

struct ReplyKeyboardMarkup
{
    KeyboardButton[][] keyboard;

    Nullable!bool      resize_keyboard;
    Nullable!bool      one_time_keyboard;
    Nullable!bool      selective;

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

    this(string text)
    {
        this.text = text;
    }

    this(string text, bool requestContact)
    {
        this(text);
        this.request_contact = requestContact;
    }

    this(string text, bool requestContact, bool requestLocation)
    {
        this(text, requestContact);
        this.request_location = requestLocation;
    }

    typeof(this) requestContact(bool value = true)
    {
        request_contact = value;

        return this;
    }

    typeof(this) requestLocation(bool value = true)
    {
        request_location = value;

        return this;
    }
}

KeyboardButton[] toKeyboardButtonRow(string[] row)
{
    return row.map!(b => KeyboardButton(b)).array;
}

struct ReplyKeyboardRemove
{
    bool remove_keyboard = true;
    Nullable!bool           selective;
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

/******************************************************************/
/*                        Telegram methods                        */
/******************************************************************/

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

struct GetUpdatesMethod
{
    mixin TelegramMethod!"/getUpdates";

    int   offset;
    ubyte limit;
    uint  timeout;
    string[] allowed_updates;
}

struct GetMeMethod
{
    mixin TelegramMethod!("/getMe", HTTPMethod.GET);
}

struct SendMessageMethod
{
    mixin TelegramMethod!"/sendMessage";

    ChatId    chat_id;
    string    text;
    Nullable!ParseMode parse_mode;
    Nullable!bool      disable_web_page_preview;
    Nullable!bool      disable_notification;
    Nullable!uint      reply_to_message_id;

    ReplyMarkup reply_markup;
}

unittest
{
    SendMessageMethod m = {
        chat_id: 111,
        text: "Message text"
    };

    assert(m.serializeToJsonString() ==
        `{"chat_id":"111","text":"Message text"}`);
}

struct ForwardMessageMethod
{
    mixin TelegramMethod!"/forwardMessage";

    ChatId chat_id;
    string from_chat_id;
    Nullable!bool   disable_notification;
    uint   message_id;
}

struct SendPhotoMethod
{
    mixin TelegramMethod!"/sendPhoto";

    ChatId      chat_id;
    string      photo;
    string      caption;
    Nullable!ParseMode   parse_mode;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

unittest
{
    SendPhotoMethod m = {
        chat_id: "111",
        photo: "Photo url"
    };

    assert(m.serializeToJsonString() ==
        `{"chat_id":"111","photo":"Photo url","disable_notification":false,"reply_to_message_id":0}`);
}

struct SendAudioMethod
{
    mixin TelegramMethod!"/sendAudio";

    ChatId      chat_id;
    string      audio;
    string      caption;
    Nullable!ParseMode   parse_mode;
    uint        duration;
    string      performer;
    string      title;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;

}

unittest
{
    SendAudioMethod m = {
        chat_id: "111",
        audio: "data"
    };

    assert(m.serializeToJsonString() ==
        `{"chat_id":"111","audio":"data","duration":0,"disable_notification":false,"reply_to_message_id":0}`);
}

struct SendDocumentMethod
{
    mixin TelegramMethod!"/sendDocument";

    ChatId      chat_id;
    string      document;
    string      caption;
    Nullable!ParseMode   parse_mode;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

unittest
{
    SendDocumentMethod m = {
        chat_id: "111",
        document: "data"
    };

    assert(m.serializeToJsonString() ==
        `{"chat_id":"111","document":"data","disable_notification":false,"reply_to_message_id":0}`);
}

struct SendVideoMethod
{
    mixin TelegramMethod!"/sendVideo";

    string      chat_id;
    string      video;
    uint        duration;
    uint        width;
    uint        height;
    string      caption;
    Nullable!ParseMode   parse_mode;
    bool        supports_streaming;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

unittest
{
    SendVideoMethod m = {
        chat_id: "111",
        video: "data"
    };

    assert(m.serializeToJsonString() ==
        `{"chat_id":"111","video":"data","duration":0,"width":0,"height":0,"supports_streaming":false,"disable_notification":false,"reply_to_message_id":0}`
    );
}

struct SendVoiceMethod
{
    mixin TelegramMethod!"/sendVoice";

    ChatId      chat_id;
    string      voice;
    string      caption;
    Nullable!ParseMode   parse_mode;
    uint        duration;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

unittest
{
    SendVoiceMethod m = {
        chat_id: "111",
        voice: "data"
    };

    assert(m.serializeToJsonString() ==
        `{"chat_id":"111","voice":"data","duration":0,"disable_notification":false,"reply_to_message_id":0}`);
}

struct SendVideoNoteMethod
{
    mixin TelegramMethod!"/sendVideoNote";

    ChatId      chat_id;
    string      video_note;
    uint        duration;
    uint        length;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

struct SendMediaGroupMethod
{
    mixin TelegramMethod!"/sendMediaGroup";

    ChatId       chat_id;
    InputMedia[] media;
    bool         disable_notification;
    uint         reply_to_message_id;
}

struct SendLocationMethod
{
    mixin TelegramMethod!"/sendLocation";

    ChatId      chat_id;
    float       latitude;
    float       longitude;
    uint        live_period;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

struct EditMessageLiveLocationMethod
{
    mixin TelegramMethod!"/editMessageLiveLocation";

    ChatId      chat_id;
    uint        message_id;
    string      inline_message_id;
    float       latitude;
    float       longitude;
    ReplyMarkup reply_markup;
}

struct StopMessageLiveLocationMethod
{
    mixin TelegramMethod!"/stopMessageLiveLocation";

    ChatId      chat_id;
    uint        message_id;
    string      inline_message_id;
    ReplyMarkup reply_markup;
}

struct SendVenueMethod
{
    mixin TelegramMethod!"/sendVenue";

    ChatId      chat_id;
    float       latitude;
    float       longitude;
    string      title;
    string      address;
    string      foursquare_id;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

struct SendContactMethod
{
    mixin TelegramMethod!"/sendContact";

    ChatId      chat_id;
    string      phone_number;
    string      first_name;
    string      last_name;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

enum ChatAction : string
{
    Typing = "typing",
    UploadPhoto = "upload_photo",
    RecordVideo = "record_video",
    UploadVideo = "upload_video",
    RecordAudio = "record_audio",
    UploadAudio = "upload_audio",
    UploadDocument = "upload_document",
    FindLocation = "find_location",
    RecordVideoNote = "record_video_note",
    UploadVideoNote = "upload_video_note"
}

struct SendChatActionMethod
{
    mixin TelegramMethod!"/sendChatAction";

    ChatId chat_id;
    string action;
}

struct GetUserProfilePhotosMethod
{
    mixin TelegramMethod!("/getUserProfilePhotos", HTTPMethod.GET);

    int  user_id;
    uint offset;
    uint limit;
}

struct GetFileMethod
{
    mixin TelegramMethod!("/getFile", HTTPMethod.GET);

    string file_id;
}

struct KickChatMemberMethod
{
    mixin TelegramMethod!"/kickChatMember";

    ChatId chat_id;
    uint   user_id;
    uint   until_date;
}

struct UnbanChatMemberMethod
{
    mixin TelegramMethod!"/unbanChatMember";

    ChatId chat_id;
    uint   user_id;
}

struct RestrictChatMemberMethod
{
    mixin TelegramMethod!"/restrictChatMember";

    ChatId chat_id;
    uint   user_id;
    uint   until_date;
    bool   can_send_messages;
    bool   can_send_media_messages;
    bool   can_send_other_messages;
    bool   can_add_web_page_previews;
}

struct PromoteChatMemberMethod
{
    mixin TelegramMethod!"/promoteChatMember";

    ChatId chat_id;
    uint   user_id;
    bool   can_change_info;
    bool   can_post_messages;
    bool   can_edit_messages;
    bool   can_delete_messages;
    bool   can_invite_users;
    bool   can_restrict_members;
    bool   can_pin_messages;
    bool   can_promote_members;
}

struct ExportChatInviteLinkMethod
{
    mixin TelegramMethod!"/exportChatInviteLink";

    ChatId chat_id;
}

struct SetChatPhotoMethod
{
    mixin TelegramMethod!"/setChatPhoto";

    ChatId    chat_id;
    InputFile photo;

}

struct DeleteChatPhotoMethod
{
    mixin TelegramMethod!"/deleteChatPhoto";

    ChatId chat_id;
}

struct SetChatTitleMethod
{
    mixin TelegramMethod!"/setChatTitle";

    ChatId chat_id;
    string title;
}

struct SetChatDescriptionMethod
{
    mixin TelegramMethod!"/setChatDescription";

    ChatId chat_id;
    string description;
}

struct PinChatMessageMethod
{
    mixin TelegramMethod!"/pinChatMessage";

    ChatId chat_id;
    uint   message_id;
    bool   disable_notification;
}

struct UnpinChatMessageMethod
{
    mixin TelegramMethod!"/unpinChatMessage";

    ChatId chat_id;
}

struct LeaveChatMethod
{
    mixin TelegramMethod!"/leaveChat";

    ChatId chat_id;
}

struct GetChatMethod
{
    mixin TelegramMethod!("/getChat", HTTPMethod.GET);

    ChatId chat_id;
}

struct GetChatAdministratorsMethod
{
    mixin TelegramMethod!("/getChatAdministrators", HTTPMethod.GET);

    ChatId chat_id;
}

struct GetChatMembersCountMethod
{
    mixin TelegramMethod!("/getChatMembersCount", HTTPMethod.GET);

    ChatId chat_id;
}

struct GetChatMemberMethod
{
    mixin TelegramMethod!("/getChatMember", HTTPMethod.GET);

    ChatId chat_id;
    uint   user_id;
}

struct SetChatStickerSetMethod
{
    mixin TelegramMethod!"/setChatStickerSet";

    ChatId chat_id;
    string sticker_set_name;
}

struct DeleteChatStickerSetMethod
{
    mixin TelegramMethod!"/deleteChatStickerSet";

    ChatId chat_id;
}

struct AnswerCallbackQueryMethod
{
    mixin TelegramMethod!"/answerCallbackQuery";

    string callback_query_id;
    string text;
    bool   show_alert;
    string url;
    uint   cache_time;
}

struct EditMessageTextMethod
{
    mixin TelegramMethod!"/editMessageTextMethod";

    ChatId      chat_id;
    uint        message_id;
    string      inline_message_id;
    string      text;
    Nullable!ParseMode   parse_mode;
    bool        disable_web_page_preview;
    ReplyMarkup reply_markup;
}

struct EditMessageCaptionMethod
{
    mixin TelegramMethod!"/editMessageCaptionMethod";

    ChatId      chat_id;
    uint        message_id;
    string      inline_message_id;
    string      caption;
    Nullable!ParseMode   parse_mode;
    ReplyMarkup reply_markup;
}

struct EditMessageReplyMarkupMethod
{
    mixin TelegramMethod!"/editMessageReplyMarkupMethod";

    ChatId      chat_id;
    uint        message_id;
    string      inline_message_id;
    ReplyMarkup reply_markup;
}

struct DeleteMessageMethod
{
    mixin TelegramMethod!"/deleteMessageMethod";

    ChatId chat_id;
    uint   message_id;
}

struct SendStickerMethod
{
    mixin TelegramMethod!"/sendStickerMethod";

    ChatId      chat_id;
    string      sticker; // TODO InputFile|string
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

struct GetStickerSetMethod
{
    mixin TelegramMethod!("/getStickerSetMethod", HTTPMethod.GET);

    string name;
}

struct UploadStickerFileMethod
{
    mixin TelegramMethod!"/uploadStickerFileMethod";

    int       user_id;
    InputFile png_sticker;
}

struct CreateNewStickerSetMethod
{
    mixin TelegramMethod!"/createNewStickerSetMethod";

    int          user_id;
    string       name;
    string       title;
    string       png_sticker; // TODO InputFile|string
    string       emojis;
    bool         contains_masks;
    MaskPosition mask_position;
}

struct AddStickerToSetMethod
{
    mixin TelegramMethod!"/addStickerToSetMethod";

    int          user_id;
    string       name;
    string       png_sticker; // TODO InputFile|string
    string       emojis;
    MaskPosition mask_position;
}

struct SetStickerPositionInSetMethod
{
    mixin TelegramMethod!"/setStickerPositionInSetMethod";

    string sticker;
    int    position;
}

struct DeleteStickerFromSetMethod
{
    mixin TelegramMethod!"/deleteStickerFromSetMethod";

    string sticker;
}

struct AnswerInlineQueryMethod
{
    mixin TelegramMethod!"/answerInlineQuery";

    string              inline_query_id;
    InlineQueryResult[] results;
    uint                cache_time;
    bool                is_personal;
    string              next_offset;
    string              switch_pm_text;
    string              switch_pm_parameter;
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

        Update[] getUpdates(int offset, ubyte limit = 5, uint timeout = 30, string[] allowedUpdates = [])
        {
            GetUpdatesMethod m = {
                offset:  offset,
                limit:   limit,
                timeout: timeout,
                allowed_updates: allowedUpdates
            };

            return callMethod!(Update[], GetUpdatesMethod)(m);
        }

        User getMe()
        {
            GetMeMethod m;

            return callMethod!(User, GetMeMethod)(m);
        }

        Message sendMessage(T)(T chatId, string text)
            if (isTelegramId!T)
        {
            SendMessageMethod m = {
                chat_id    : chatId,
                text       : text,
            };

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
                message_id : messageId,
                chat_id : chatId,
                from_chat_id: fromChatId,
            };

            return callMethod!(Message, ForwardMessageMethod)(m);
        }

        Message forwardMessage(ref ForwardMessageMethod m)
        {
            return callMethod!(Message, ForwardMessageMethod)(m);
        }

        Message sendPhoto(ref SendPhotoMethod m)
        {
            return callMethod!(Message, SendPhotoMethod)(m);
        }

        Message sendPhoto(T1)(T1 chatId, string photo)
            if (isTelegramId!T1)
        {
            SendPhotoMethod m = {
                chat_id : chatId,
                photo : photo,
            };

            return sendPhoto(m);
        }

        Message sendAudio(ref SendAudioMethod m)
        {
            return callMethod!(Message, SendAudioMethod)(m);
        }

        Message sendAudio(T1)(T1 chatId, string audio)
            if (isTelegramId!T1)
        {
            SendAudioMethod m = {
                chat_id : chatId,
                audio : audio
            };

            return sendAudio(m);
        }

        Message sendDocument(ref SendDocumentMethod m)
        {
            return callMethod!(Message, SendDocumentMethod)(m);
        }

        Message sendDocument(T1)(T1 chatId, string document)
            if (isTelegramId!T1)
        {
            SendDocumentMethod m = {
                chat_id : chatId,
                document : document
            };

            return sendDocument(m);
        }

        Message sendVideo(ref SendVideoMethod m)
        {
            return callMethod!(Message, SendVideoMethod)(m);
        }

        Message sendVideo(T1)(T1 chatId, string video)
            if (isTelegramId!T1)
        {
            SendVideoMethod m = {
                chat_id : chatId,
                video : video
            };

            return sendVideo(m);
        }

        Message sendVoice(ref SendVoiceMethod m)
        {
            return callMethod!(Message, SendVoiceMethod)(m);
        }

        Message sendVoice(T1)(T1 chatId, string voice)
            if (isTelegramId!T1)
        {
            SendVoiceMethod m = {
                chat_id : chatId,
                voice : voice
            };

            return sendVoice(m);
        }

        Message sendVideoNote(ref SendVideoNoteMethod m)
        {
            return callMethod!(Message, SendVideoNoteMethod)(m);
        }

        Message sendVideoNote(T1)(T1 chatId, string videoNote)
            if (isTelegramId!T1)
        {
            SendVideoNoteMethod m = {
                chat_id : chatId,
                video_note : videoNote
            };

            return sendVideoNote(m);
        }

        Message sendMediaGroup(ref SendMediaGroupMethod m)
        {
            return callMethod!(Message, SendMediaGroupMethod)(m);
        }

        Message sendMediaGroup(T1)(T1 chatId, InputMedia[] media)
            if (isTelegramId!T1)
        {
            SendMediaGroupMethod m = {
                chat_id : chatId,
                media : media
            };

            return sendMediaGroup(m);
        }

        Message sendLocation(ref SendLocationMethod m)
        {
            return callMethod!(Message, SendLocationMethod)(m);
        }

        Message sendLocation(T1)(T1 chatId, float latitude, float longitude)
            if (isTelegramId!T1)
        {
            SendLocationMethod m = {
                chat_id : chatId,
                latitude : latitude,
                longitude : longitude,
            };

            return sendLocation(m);
        }

        Nullable!Message editMessageLiveLocation(ref EditMessageLiveLocationMethod m)
        {
            return callMethod!(Nullable!Message, EditMessageLiveLocationMethod)(m);
        }

        Nullable!Message editMessageLiveLocation(string inlineMessageId, float latitude, float longitude)
        {
            EditMessageLiveLocationMethod m = {
                inline_message_id : inlineMessageId,
                latitude : latitude,
                longitude : longitude
            };

            return editMessageLiveLocation(m);
        }

        Nullable!Message editMessageLiveLocation(T1)(T1 chatId, uint messageId, float latitude, float longitude)
            if (isTelegramId!T1)
        {
            EditMessageLiveLocationMethod m = {
                chat_id : chatId,
                message_id : messageId,
                latitude : latitude,
                longitude : longitude
            };

            return editMessageLiveLocation(m);
        }

        Nullable!Message stopMessageLiveLocation(ref StopMessageLiveLocationMethod m)
        {
            return callMethod!(Nullable!Message, StopMessageLiveLocationMethod)(m);
        }

        Nullable!Message stopMessageLiveLocation(string inlineMessageId)
        {
            StopMessageLiveLocationMethod m = {
                inline_message_id : inlineMessageId
            };

            return stopMessageLiveLocation(m);
        }

        Nullable!Message stopMessageLiveLocation(T1)(T1 chatId, uint messageId)
            if (isTelegramId!T1)
        {
            StopMessageLiveLocationMethod m = {
                chat_id : chatId,
                message_id : messageId
            };

            return stopMessageLiveLocation(m);
        }

        Message sendVenue(ref SendVenueMethod m)
        {
            return callMethod!(Message, SendVenueMethod)(m);
        }

        Message sendVenue(T1)(T1 chatId, float latitude, float longitude,
            string title, string address)
            if (isTelegramId!T1)
        {
            SendVenueMethod m = {
                chat_id : chatId,
                latitude : latitude,
                longitude : longitude,
                title : title,
                address : address
            };

            return sendVenue(m);
        }

        Message sendContact(ref SendContactMethod m)
        {
            return callMethod!(Message, SendContactMethod)(m);
        }

        Message sendContact(T1)(T1 chatId, string phone_number, string first_name)
            if (isTelegramId!T1)
        {
            SendContactMethod m = {
                chat_id : chatId,
                phone_number : phone_number,
                first_name : first_name
            };

            return sendContact(m);
        }

        bool sendChatAction(ref SendChatActionMethod m)
        {
            return callMethod!(bool, SendChatActionMethod)(m);
        }

        bool sendChatAction(T1)(T1 chatId, string action)
            if (isTelegramId!T1)
        {
            SendChatActionMethod m = {
                chat_id : chatId,
                action : action
            };

            return sendChatAction(m);
        }

        UserProfilePhotos getUserProfilePhotos(ref GetUserProfilePhotosMethod m)
        {
            return callMethod!(UserProfilePhotos, GetUserProfilePhotosMethod)(m);
        }

        UserProfilePhotos getUserProfilePhotos(int userId)
        {
            GetUserProfilePhotosMethod m = {
                user_id : userId
            };

            return getUserProfilePhotos(m);
        }

        File getFile(ref GetFileMethod m)
        {
            return callMethod!(File, GetFileMethod)(m);
        }

        File getFile(string fileId)
        {
            GetFileMethod m = {
                file_id : fileId
            };

            return getFile(m);
        }

        bool kickChatMember(ref KickChatMemberMethod m)
        {
            return callMethod!(bool, KickChatMemberMethod)(m);
        }

        bool kickChatMember(T1)(T1 chatId, int userId)
            if(isTelegramId!T1)
        {
            KickChatMemberMethod m = {
                chat_id : chatId,
                user_id : userId
            };

            return kickChatMember(m);
        }

        bool unbanChatMember(ref UnbanChatMemberMethod m)
        {
            return callMethod!(bool, UnbanChatMemberMethod)(m);
        }

        bool unbanChatMember(T1)(T1 chatId, int userId)
            if(isTelegramId!T1)
        {
            UnbanChatMemberMethod m = {
                chat_id : chatId,
                user_id : userId
            };

            return unbanChatMember(m);
        }

        bool restrictChatMember(ref RestrictChatMemberMethod m)
        {
            return callMethod!bool(m);
        }

        bool restrictChatMember(T1)(T1 chatId, int userId)
            if(isTelegramId!T1)
        {
            RestrictChatMemberMethod m = {
                chat_id : chatId,
                user_id : userId
            };

            return restrictChatMember(m);
        }

        bool promoteChatMember(ref PromoteChatMemberMethod m)
        {
            return callMethod!bool(m);
        }

        bool promoteChatMember(T1)(T1 chatId, int userId)
            if(isTelegramId!T1)
        {
            PromoteChatMemberMethod m = {
                chat_id : chatId,
                user_id : userId
            };

            return promoteChatMember(m);
        }

        string exportChatInviteLink(ref ExportChatInviteLinkMethod m)
        {
            return callMethod!string(m);
        }

        string exportChatInviteLink(T1)(T1 chatId)
            if(isTelegramId!T1)
        {
            ExportChatInviteLinkMethod m = {
                chat_id : chatId,
            };

            return exportChatInviteLink(m);
        }

        bool setChatPhoto(ref SetChatPhotoMethod m)
        {
            return callMethod!bool(m);
        }

        bool setChatPhoto(T1)(T1 chatId, InputFile photo)
            if (isTelegramId!T1)
        {
            SetChatPhotoMethod m = {
                chat_id : chatId,
                photo : photo
            };

            return setChatPhoto(m);
        }

        bool deleteChatPhoto(ref DeleteChatPhotoMethod m)
        {
            return callMethod!bool(m);
        }

        bool deleteChatPhoto(T1)(T1 chatId)
            if (isTelegramId!T1)
        {
            DeleteChatPhotoMethod m = {
                chat_id : chatId,
            };

            return deleteChatPhoto(m);
        }

        bool setChatTitle(ref SetChatTitleMethod m)
        {
            return callMethod!bool(m);
        }

        bool setChatTitle(T1)(T1 chatId, string title)
            if (isTelegramId!T1)
        {
            SetChatTitleMethod m = {
                chat_id : chatId,
                title : title
            };

            return setChatTitle(m);
        }

        bool setChatDescription(ref SetChatDescriptionMethod m)
        {
            return callMethod!bool(m);
        }

        bool setChatDescription(T1)(T1 chatId, string description)
            if (isTelegramId!T1)
        {
            SetChatDescriptionMethod m = {
                chat_id : chatId,
                description : description
            };

            return setChatDescription(m);
        }

        bool pinChatMessage(ref PinChatMessageMethod m)
        {
            return callMethod!bool(m);
        }

        bool pinChatMessage(T1)(T1 chatId, uint messageId)
            if (isTelegramId!T1)
        {
            PinChatMessageMethod m = {
                chat_id : chatId,
                message_id : messageId
            };

            return pinChatMessage(m);
        }

        bool unpinChatMessage(ref UnpinChatMessageMethod m)
        {
            return callMethod!bool(m);
        }

        bool unpinChatMessage(T1)(T1 chatId)
            if (isTelegramId!T1)
        {
            UnpinChatMessageMethod m = {
                chat_id : chatId,
            };

            return unpinChatMessage(m);
        }

        bool leaveChat(ref LeaveChatMethod m)
        {
            return callMethod!bool(m);
        }

        bool leaveChat(T1)(T1 chatId)
            if (isTelegramId!T1)
        {
            LeaveChatMethod m = {
                chat_id : chatId,
            };

            return leaveChat(m);
        }

        Chat getChat(ref GetChatMethod m)
        {
            return callMethod!Chat(m);
        }

        Chat getChat(T1)(T1 chatId)
            if (isTelegramId!T1)
        {
            GetChatMethod m = {
                chat_id : chatId,
            };

            return getChat(m);
        }

        ChatMember getChatAdministrators(ref GetChatAdministratorsMethod m)
        {
            return callMethod!ChatMember(m);
        }

        ChatMember getChatAdministrators(T1)(T1 chatId)
            if (isTelegramId!T1)
        {
            GetChatAdministratorsMethod m = {
                chat_id : chatId,
            };

            return getChatAdministrators(m);
        }

        uint getChatMembersCount(ref GetChatMembersCountMethod m)
        {
            return callMethod!uint(m);
        }

        uint getChatMembersCount(T1)(T1 chatId)
            if (isTelegramId!T1)
        {
            GetChatMembersCountMethod m = {
                chat_id : chatId,
            };

            return getChatMembersCount(m);
        }

        ChatMember getChatMember(ref GetChatMemberMethod m)
        {
            return callMethod!ChatMember(m);
        }

        ChatMember getChatMember(T1)(T1 chatId, int userId)
            if (isTelegramId!T1)
        {
            GetChatMemberMethod m = {
                chat_id : chatId,
                user_id : userId
            };

            return getChatMember(m);
        }

        bool setChatStickerSet(ref SetChatStickerSetMethod m)
        {
            return callMethod!bool(m);
        }

        bool setChatStickerSet(T1)(T1 chatId, string stickerSetName)
            if (isTelegramId!T1)
        {
            SetChatStickerSetMethod m = {
                chat_id : chatId,
                sticker_set_name : stickerSetName
            };

            return setChatStickerSet(m);
        }

        bool deleteChatStickerSet(ref DeleteChatStickerSetMethod m)
        {
            return callMethod!bool(m);
        }

        bool deleteChatStickerSet(T1)(T1 chatId)
            if (isTelegramId!T1)
        {
            DeleteChatStickerSetMethod m = {
                chat_id : chatId,
            };

            return deleteChatStickerSet(m);
        }

        bool answerCallbackQuery(ref AnswerCallbackQueryMethod m)
        {
            return callMethod!bool(m);
        }

        bool answerCallbackQuery(string callbackQueryId)
        {
            AnswerCallbackQueryMethod m = {
                callback_query_id : callbackQueryId
            };

            return answerCallbackQuery(m);
        }

        bool editMessageText(ref EditMessageTextMethod m)
        {
            return callMethod!bool(m);
        }

        bool editMessageText(T1)(T1 chatId, uint messageId, string text)
            if (isTelegramId!T1)
        {
            EditMessageTextMethod m = {
                chat_id : chatId,
                message_id : messageId,
                text : text
            };

            return editMessageText(m);
        }

        bool editMessageText(string inlineMessageId, string text)
        {
            EditMessageTextMethod m = {
                inline_message_id : inlineMessageId,
                text : text
            };

            return editMessageText(m);
        }

        bool editMessageCaption(ref EditMessageCaptionMethod m)
        {
            return callMethod!bool(m);
        }

        bool editMessageCaption(T1)(T1 chatId, uint messageId, string caption = null)
            if (isTelegramId!T1)
        {
            EditMessageCaptionMethod m = {
                chat_id : chatId,
                message_id : messageId,
                caption : caption
            };

            return editMessageCaption(m);
        }

        bool editMessageCaption(string inlineMessageId, string caption = null)
        {
            EditMessageCaptionMethod m = {
                inline_message_id : inlineMessageId,
                caption : caption
            };

            return editMessageCaption(m);
        }

        bool editMessageReplyMarkup(ref EditMessageReplyMarkupMethod m)
        {
            return callMethod!bool(m);
        }

        bool editMessageReplyMarkup(T1, T2)(T1 chatId, uint messageId, T2 replyMarkup)
            if (isTelegramId!T1 && isReplyMarkup!T2)
        {
            EditMessageReplyMarkupMethod m = {
                chat_id : chatId,
                message_id : messageId
            };

            m.reply_markup = replyMarkup;

            return editMessageReplyMarkup(m);
        }

        bool editMessageReplyMarkup(string inlineMessageId, Nullable!ReplyMarkup replyMarkup)
        {
            EditMessageReplyMarkupMethod m = {
                inline_message_id : inlineMessageId,
                reply_markup : replyMarkup
            };

            return editMessageReplyMarkup(m);
        }

        bool deleteMessage(ref DeleteMessageMethod m)
        {
            return callMethod!bool(m);
        }

        bool deleteMessage(T1)(T1 chatId, uint messageId)
            if (isTelegramId!T1)
        {
            DeleteMessageMethod m = {
                chat_id : chatId,
                message_id : messageId
            };

            return deleteMessage(m);
        }

        Message sendSticker(ref SendStickerMethod m)
        {
            return callMethod!Message(m);
        }

        // TODO sticker is InputFile|string
        Message sendSticker(T1)(T1 chatId, string sticker)
            if (isTelegramId!T1)
        {
            SendStickerMethod m = {
                chat_id : chatId,
                sticker : sticker
            };

            return sendSticker(m);
        }

        StickerSet getStickerSet(ref GetStickerSetMethod m)
        {
            return callMethod!StickerSet(m);
        }

        StickerSet getStickerSet(string name)
        {
            GetStickerSetMethod m = {
                name : name
            };

            return getStickerSet(m);
        }

        File uploadStickerFile(ref UploadStickerFileMethod m)
        {
            return callMethod!File(m);
        }

        File uploadStickerFile(int userId, InputFile pngSticker)
        {
            UploadStickerFileMethod m = {
                user_id : userId,
                png_sticker : pngSticker
            };

            return uploadStickerFile(m);
        }

        bool createNewStickerSet(ref CreateNewStickerSetMethod m)
        {
            return callMethod!bool(m);
        }

        // TODO pngSticker is InputFile|string
        bool createNewStickerSet(int userId, string name, string title, string pngSticker, string emojis)
        {
            CreateNewStickerSetMethod m = {
                user_id : userId,
                name : name,
                title : title,
                png_sticker : pngSticker,
                emojis : emojis
            };

            return createNewStickerSet(m);
        }

        bool addStickerToSet(ref AddStickerToSetMethod m)
        {
            return callMethod!bool(m);
        }

        bool addStickerToSet(int userId, string name, string pngSticker, string emojis)
        {
            AddStickerToSetMethod m = {
                user_id : userId,
                name : name,
                png_sticker : pngSticker,
                emojis : emojis
            };

            return addStickerToSet(m);
        }

        bool setStickerPositionInSet(ref SetStickerPositionInSetMethod m)
        {
            return callMethod!bool(m);
        }

        bool setStickerPositionInSet(string sticker, uint position)
        {
            SetStickerPositionInSetMethod m = {
                sticker : sticker,
                position : position
            };

            return setStickerPositionInSet(m);
        }

        bool deleteStickerFromSet(ref DeleteStickerFromSetMethod m)
        {
            return callMethod!bool(m);
        }

        bool deleteStickerFromSet(string sticker)
        {
            DeleteStickerFromSetMethod m = {
                sticker : sticker
            };

            return deleteStickerFromSet(m);
        }

        bool answerInlineQuery(ref AnswerInlineQueryMethod m)
        {
            return callMethod!bool(m);
        }

        bool answerInlineQuery(string inlineQueryId, InlineQueryResult[] results)
        {
            AnswerInlineQueryMethod m = {
                inline_query_id : inlineQueryId,
                results : results
            };

            return answerInlineQuery(m);
        }

        unittest
        {
            class BotApiMock : BotApi
            {
                this(string token)
                {
                    super(token);
                }

                T callMethod(T, M)(M method)
                {
                    T result;

                    logDiagnostic("[%d] Requesting %s", requestCounter, method.name);

                    return result;
                }
            }

            auto api = new BotApiMock(null);

            api.getUpdates(5,30);
            api.getMe();
            api.sendMessage("chat-id", "hello");
            api.forwardMessage("chat-id", "from-chat-id", 123);
            api.sendPhoto("chat-id", "photo-url");
            api.sendAudio("chat-id", "audio-url");
            api.sendDocument("chat-id", "document-url");
            api.sendVideo("chat-id", "video-url");
            api.sendVoice("chat-id", "voice-url");
            api.sendVideoNote("chat-id", "video-note-url");
            api.sendMediaGroup("chat-id", []);
            api.sendLocation("chat-id", 123, 123);
            api.editMessageLiveLocation("chat-id", 1, 1.23, 4.56);
            api.editMessageLiveLocation("inline-message-id", 1.23, 4.56);
            api.stopMessageLiveLocation("chat-id", 1);
            api.stopMessageLiveLocation("inline-message-id");
            api.sendVenue("chat-id", 123, 123, "title", "address");
            api.sendContact("chat-id", "+123", "First Name");
            api.sendChatAction("chat-id", "typing");
            api.getUserProfilePhotos(1);
            api.getFile("file-id");
            api.kickChatMember("chat-id", 1);
            api.unbanChatMember("chat-id", 1);
            api.restrictChatMember("chat-id", 1);
            api.promoteChatMember("chat-id", 1);
            api.exportChatInviteLink("chat-id");
            api.setChatPhoto("chat-id", InputFile());
            api.deleteChatPhoto("chat-id");
            api.setChatTitle("chat-id", "chat-title");
            api.setChatDescription("chat-id", "chat-description");
            api.pinChatMessage("chat-id", 1);
            api.unpinChatMessage("chat-id");
            api.leaveChat("chat-id");
            api.getChat("chat-id");
            api.getChatAdministrators("chat-id");
            api.getChatMembersCount("chat-id");
            api.getChatMember("chat-id", 1);
            api.setChatStickerSet("chat-id", "sticker-set");
            api.deleteChatStickerSet("chat-id");
            api.answerCallbackQuery("callback-query-id");
            api.editMessageText("chat-id", 123, "new text");
            api.editMessageText("inline-message-id", "new text");
            api.editMessageCaption("chat-id", 123, "new caption");
            api.editMessageCaption("chat-id", 123, null);
            api.editMessageCaption("inline-message-id", "new caption");
            api.editMessageCaption("inline-message-id", null);

            api.editMessageReplyMarkup("chat-id", 123, ForceReply());
            api.editMessageReplyMarkup("chat-id", 123, ReplyKeyboardMarkup());
            api.editMessageReplyMarkup("chat-id", 123, ReplyKeyboardRemove());
            api.editMessageReplyMarkup("chat-id", 123, InlineKeyboardMarkup());
            api.editMessageReplyMarkup("chat-id", 123, ReplyMarkup());

            api.deleteMessage("chat-id", 123);
            api.sendSticker("chat-id", "sticker");
            api.getStickerSet("sticker-set");
            api.uploadStickerFile(1, InputFile());
            api.createNewStickerSet(1, "name", "title", "png-sticker", "emojis");
            api.addStickerToSet(1, "name", "png-sticker", "emojis");
            api.setStickerPositionInSet("sticker", 42);
            api.deleteStickerFromSet("sticker");

            InlineQueryResult[] iqr = new InlineQueryResult[20];

            iqr[0] = InlineQueryResultArticle();
            iqr[1] = InlineQueryResultPhoto();
            iqr[2] = InlineQueryResultGif();
            iqr[3] = InlineQueryResultMpeg4Gif();
            iqr[4] = InlineQueryResultVideo();
            iqr[5] = InlineQueryResultAudio();
            iqr[6] = InlineQueryResultVoice();
            iqr[7] = InlineQueryResultDocument();
            iqr[8] = InlineQueryResultLocation();
            iqr[9] = InlineQueryResultVenue();
            iqr[10] = InlineQueryResultContact();
            iqr[11] = InlineQueryResultGame();
            iqr[12] = InlineQueryResultCachedPhoto();
            iqr[13] = InlineQueryResultCachedGif();
            iqr[14] = InlineQueryResultCachedMpeg4Gif();
            iqr[15] = InlineQueryResultCachedSticker();
            iqr[16] = InlineQueryResultCachedDocument();
            iqr[17] = InlineQueryResultCachedVideo();
            iqr[18] = InlineQueryResultCachedVoice();
            iqr[19] = InlineQueryResultCachedAudio();

            api.answerInlineQuery("answer-inline-query", iqr);
        }
}

class UpdatesRange
{
    import std.algorithm.comparison : max;

    enum bool empty = false;

    protected:
        BotApi _api;
        uint _maxUpdateId;

        string[] _allowedUpdates = [];
        ubyte _updatesLimit = 5;
        uint _timeout = 30;

    private:
        bool _isEmpty;
        Update[] _updates;
        ushort _index;

    public: @safe:
        this(BotApi api, uint maxUpdateId = 0, ubyte limit = 5, uint timeout = 30)
        {
            _api = api;
            _maxUpdateId = maxUpdateId;
            _updatesLimit = limit;
            _timeout = timeout;

            _updates.reserve(_updatesLimit);
        }

        @property
        uint maxUpdateId()
        {
            return _maxUpdateId;
        }

        auto front()
        {
            if (_updates.length == 0) {
                getUpdates();
                _maxUpdateId = max(_maxUpdateId, _updates[_index].id);
            }

            return _updates[_index];
        }

        void popFront()
        {
            _maxUpdateId = max(_maxUpdateId, _updates[_index].id);

            if (++_index >= _updates.length) {
                getUpdates();
            }
        }

    protected:
        @trusted
        void getUpdates()
        {
            do {
                _updates = _api.getUpdates(
                    _maxUpdateId+1,
                    _updatesLimit,
                    _timeout,
                    _allowedUpdates
                );
            } while (_updates.length == 0);
            _index = 0;
        }
}
