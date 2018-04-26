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

    void opAssign(T)(T value)
        if (staticIndexOf!(T, Typelist) >= 0)
    {
        types = value;
    }

    @safe
    Json toJson() const
    {
        if (!types.hasValue) {
            return Json(null);
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

    jsonable = S1(42);
    assert(`{"s1":42}` == jsonable.serializeToJsonString());

    jsonable = S2("s2 value");
    assert(`{"s2":"s2 value"}` == jsonable.serializeToJsonString());
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

struct MessageBase
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

struct Message
{
    MessageBase          baseMessage;
    Nullable!MessageBase reply_to_message;
    Nullable!MessageBase pinned_message;

    alias baseMessage this;
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

import std.meta : AliasSeq;
import std.variant : Algebraic;

alias ReplyMarkupStructs = AliasSeq!(ReplyKeyboardMarkup, ReplyKeyboardRemove, InlineKeyboardMarkup, ForceReply);

/**
 Abstract structure for unioining ReplyKeyboardMarkup, ReplyKeyboardRemove,
 InlineKeyboardMarkup and ForceReply
*/
alias ReplyMarkup = JsonableAlgebraic!ReplyMarkupStructs;

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
    immutable string type = "article";
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
    immutable string type = "photo";
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
    immutable string type = "gif";
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
    immutable string type ="mpeg4_gif";
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
    immutable string type ="video";
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
    const string type = "audio";
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
    const string type = "voice";
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
    const string type = "document";
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
    const string type = "location";
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
    const string type = "venue";
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
    const string type = "contact";
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
    const string type = "game";
    string id;
    string game_short_name;
    Nullable!InlineKeyboardMarkup reply_markup;
}


struct InlineQueryResultCachedPhoto
{
    const string type = "photo";
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
    const string type = "gif";
    string id;
    string gif_file_id;
    string title;
    string caption;
    ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedMpeg4Gif
{
    const string type = "mpeg4_gif";
    string id;
    string mpeg4_file_id;
    string title;
    string caption;
    ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedSticker
{
    const string type = "sticker";
    string id;
    string sticker_file_id;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedDocument
{
    const string type = "document";
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
    const string type = "video";
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
    const string type = "voice";
    string    id;
    string    voice_file_id;
    string    title;
    string    caption;
    ParseMode parse_mode;

    mixin InlineQueryFields;
}


struct InlineQueryResultCachedAudio
{
    const string type = "audio";
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

struct SetWebhookMethod
{
    mixin TelegramMethod;

    package
    string name = "/setWebhook";

    string             url;
    Nullable!InputFile certificate;
    uint               max_connections;
    string[]           allowed_updates;
}

struct DeleteWebhookMethod
{
    mixin TelegramMethod;

    package
    string name = "/deleteWebhook";
}

struct GetWebhookInfoMethod
{
    mixin TelegramMethod;

    package
    string name = "/getWebhookInfo";
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
    bool      disable_web_page_preview;
    bool      disable_notification;
    uint      reply_to_message_id;

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

struct SendPhotoMethod
{
    mixin TelegramMethod;

    package
    string name = "/sendPhoto";

    string      chat_id;
    string      photo;
    string      caption;
    ParseMode   parse_mode;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

struct SendAudioMethod
{
    mixin TelegramMethod;

    package
    string name = "/sendAudio";

    string      chat_id;
    string      audio;
    string      caption;
    ParseMode   parse_mode;
    uint        duration;
    string      performer;
    string      title;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;

}

struct SendDocumentMethod
{
    mixin TelegramMethod;

    package
    string name = "/sendDocument";

    string      chat_id;
    string      document;
    string      caption;
    ParseMode   parse_mode;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

struct SendVideoMethod
{
    mixin TelegramMethod;

    package
    string name = "/sendVideo";

    string      chat_id;
    string      video;
    uint        duration;
    uint        width;
    uint        height;
    string      caption;
    ParseMode   parse_mode;
    bool        supports_streaming;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

struct SendVoiceMethod
{
    mixin TelegramMethod;

    package
    string name = "/sendVoice";

    string      chat_id;
    string      voice;
    string      caption;
    ParseMode   parse_mode;
    uint        duration;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

struct SendVideoNoteMethod
{
    mixin TelegramMethod;

    package
    string name = "/sendVideoNote";

    string      chat_id;
    string      video_note;
    uint        duration;
    uint        length;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;

}

struct SendMediaGroupMethod
{
    mixin TelegramMethod;

    package
    string name = "/sendMediaGroup";

    string       chat_id;
    InputMedia[] media;
    bool         disable_notification;
    uint         reply_to_message_id;
}

struct SendLocationMethod
{
    mixin TelegramMethod;

    package
    string name = "/sendLocation";

    string      chat_id;
    float       latitude;
    float       longitude;
    uint        live_period;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

struct editMessageLiveLocationMethod
{
    mixin TelegramMethod;

    package
    string name = "/editMessageLiveLocation";

    string      chat_id;
    uint        message_id;
    string      inline_message_id;
    float       latitude;
    float       longitude;
    ReplyMarkup reply_markup;
}

struct stopMessageLiveLocationMethod
{
    mixin TelegramMethod;

    package
    string name = "/stopMessageLiveLocation";

    string      chat_id;
    uint        message_id;
    string      inline_message_id;
    ReplyMarkup reply_markup;
}

struct SendVenueMethod
{
    mixin TelegramMethod;

    package
    string name = "/sendVenue";

    string      chat_id;
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
    mixin TelegramMethod;

    package
    string name = "/sendContact";

    string      chat_id;
    string      phone_number;
    string      first_name;
    string      last_name;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

struct sendChatActionMethod
{
    mixin TelegramMethod;

    package
    string name = "/sendChatAction";

    string chat_id;
    string action; // TODO enum
}

struct getUserProfilePhotosMethod
{
    mixin TelegramMethod;

    package
    string name = "/getUserProfilePhotos";

    int  user_id;
    uint offset;
    uint limit;
}

struct getFileMethod
{
    mixin TelegramMethod;

    package
    string name = "/getFile";

    string file_id;
}

struct kickChatMemberMethod
{
    mixin TelegramMethod;

    package
    string name = "/kickChatMember";

    string chat_id;
    uint   user_id;
    uint   until_date;
}

struct unbanChatMemberMethod
{
    mixin TelegramMethod;

    package
    string name = "/unbanChatMember";

    string chat_id;
    uint   user_id;
}

struct restrictChatMemberMethod
{
    mixin TelegramMethod;

    package
    string name = "/restrictChatMember";

    string chat_id;
    uint   user_id;
    uint   until_date;
    bool   can_send_messages;
    bool   can_send_media_messages;
    bool   can_send_other_messages;
    bool   can_add_web_page_previews;
}

struct promoteChatMemberMethod
{
    mixin TelegramMethod;

    package
    string name = "/promoteChatMember";

    string chat_id;
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

struct exportChatInviteLinkMethod
{
    mixin TelegramMethod;

    package
    string name = "/exportChatInviteLink";

    string chat_id;
}

struct setChatPhotoMethod
{
    mixin TelegramMethod;

    package
    string name = "/setChatPhoto";

    string    chat_id;
    InputFile photo;

}

struct deleteChatPhotoMethod
{
    mixin TelegramMethod;

    package
    string name = "/deleteChatPhoto";

    string chat_id;
}

struct setChatTitleMethod
{
    mixin TelegramMethod;

    package
    string name = "/setChatTitle";

    string chat_id;
    string title;
}

struct setChatDescriptionMethod
{
    mixin TelegramMethod;

    package
    string name = "/setChatDescription";

    string chat_id;
    string description;
}

struct pinChatMessageMethod
{
    mixin TelegramMethod;

    package
    string name = "/pinChatMessage";

    string chat_id;
    uint   message_id;
    bool   disable_notification;
}

struct unpinChatMessageMethod
{
    mixin TelegramMethod;

    package
    string name = "/unpinChatMessage";

    string chat_id;
}

struct leaveChatMethod
{
    mixin TelegramMethod;

    package
    string name = "/leaveChat";

    string chat_id;
}

struct getChatMethod
{
    mixin TelegramMethod;

    package
    string name = "/getChat";

    string chat_id;
}

struct getChatAdministratorsMethod
{
    mixin TelegramMethod;

    package
    string name = "/getChatAdministrators";

    string chat_id;
}

struct getChatMembersCountMethod
{
    mixin TelegramMethod;

    package
    string name = "/getChatMembersCount";

    string chat_id;
}

struct getChatMemberMethod
{
    mixin TelegramMethod;

    package
    string name = "/getChatMember";

    string chat_id;
    uint   user_id;
}

struct setChatStickerSetMethod
{
    mixin TelegramMethod;

    package
    string name = "/setChatStickerSet";

    string chat_id;
    string sticker_set_name;
}

struct deleteChatStickerSetMethod
{
    mixin TelegramMethod;

    package
    string name = "/deleteChatStickerSet";

    string chat_id;
}

struct answerCallbackQueryMethod
{
    mixin TelegramMethod;

    package
    string name = "/answerCallbackQuery";

    string callback_query_id;
    string text;
    bool   show_alert;
    string url;
    uint   cache_time;
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

            version(unittest)
            {

            } else {
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
            }

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

        bool setWebhook(string url)
        {
            SetWebhookMethod m = {
                url : url
            };

            return setWebhook(m);
        }

        bool setWebhook(ref SetWebhookMethod m)
        {
            return callMethod!(bool, SetWebhookMethod)(m);
        }

        bool deleteWebhook()
        {
            DeleteWebhookMethod m = DeleteWebhookMethod();

            return callMethod!(bool, DeleteWebhookMethod)(m);
        }

        WebhookInfo getWebhookInfo()
        {
            GetWebhookInfoMethod m = GetWebhookInfoMethod();

            return callMethod!(WebhookInfo, GetWebhookInfoMethod)(m);
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

        Message sendPhoto(ref SendPhotoMethod m)
        {
            return callMethod!(Message, SendPhotoMethod)(m);
        }

        Message sendPhoto(T1)(T1 chatId, string photo)
            if (isTelegramId!T1)
        {
            SendPhotoMethod m = {
                photo : photo
            };

            static if (isIntegral!T1) {
                m.chat_id = chatId.to!string;
            } else {
                m.chat_id = chatId;
            }

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
                audio : audio
            };

            static if (isIntegral!T1) {
                m.chat_id = chatId.to!string;
            } else {
                m.chat_id = chatId;
            }

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
                document : document
            };

            static if (isIntegral!T1) {
                m.chat_id = chatId.to!string;
            } else {
                m.chat_id = chatId;
            }

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
                video : video
            };

            static if (isIntegral!T1) {
                m.chat_id = chatId.to!string;
            } else {
                m.chat_id = chatId;
            }

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
                voice : voice
            };

            static if (isIntegral!T1) {
                m.chat_id = chatId.to!string;
            } else {
                m.chat_id = chatId;
            }

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
                video_note : videoNote
            };

            static if (isIntegral!T1) {
                m.chat_id = chatId.to!string;
            } else {
                m.chat_id = chatId;
            }

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
                media : media
            };

            static if (isIntegral!T1) {
                m.chat_id = chatId.to!string;
            } else {
                m.chat_id = chatId;
            }

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
                latitude : latitude,
                longitude : longitude,
            };

            static if (isIntegral!T1) {
                m.chat_id = chatId.to!string;
            } else {
                m.chat_id = chatId;
            }

            return sendLocation(m);
        }

        // sendVenue
        // sendContact
        // sendChatAction

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
            api.setWebhook("https://webhook.url");
            api.deleteWebhook();
            api.getWebhookInfo();
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
        }
}
