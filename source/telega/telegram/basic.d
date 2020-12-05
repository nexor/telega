module telega.telegram.basic;

import std.typecons : Nullable, nullable;
import asdf : Asdf, serializedAs, deserialize;
import telega.serialization : JsonableAlgebraicProxy, SerializableEnumProxy, serializeToJsonString;
import telega.botapi : BotApi, TelegramMethod, HTTPMethod, ChatId, isTelegramId;
import telega.telegram.stickers : Sticker;
import telega.telegram.games : Game, Animation, CallbackGame;
import telega.telegram.payments : Invoice, SuccessfulPayment, ShippingQuery, PreCheckoutQuery;
import telega.telegram.inline : InlineQuery;
import telega.telegram.poll : Poll, PollAnswer;


version (unittest)
{
    import telega.test : assertEquals;
}

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

    u.last_name.isNull
        .assertEquals(true);
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

    u.last_name.isNull
        .assertEquals(false);
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

    c.id
        .assertEquals(42);
    c.type
        .assertEquals(ChatType.Group);
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
    Nullable!string      forward_sender_name;
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
    Nullable!Poll            poll;
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
    Nullable!Poll               poll;
    Nullable!PollAnswer         poll_answer;

    @property @safe @nogc nothrow pure
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

    u.id
        .assertEquals(143);
    u.message.message_id
        .assertEquals(243);
    u.message.text.get
        .assertEquals("message text");
}

enum ParseMode : string
{
    Markdown = "Markdown",
    HTML     = "HTML",
    None     = "",
}

enum MessageEntityType : string
{
    Mention = "mention",
    Hashtag = "hashtag",
    Cashtag = "cashtag",
    BotCommand = "bot_command",
    Url = "url",
    Email = "email",
    PhoneNumber = "phone_number",
    Bold = "bold",
    Italic = "italic",
    Underline = "underline",
    Strikethrough = "strikethrough",
    Code = "code",
    Pre = "pre",
    TextLink = "text_link",
    TextMension = "text_mention"
}

struct MessageEntity
{
    MessageEntityType        type;
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

struct Contact
{
    string phone_number;
    string first_name;
    Nullable!string last_name;
    Nullable!uint user_id;
    Nullable!string vcard;
}

unittest
{
    string json = `{
        "phone_number": "+123456789",
        "first_name": "FirstName",
        "last_name": "LstName",
        "user_id": 42
    }`;

    Contact c = deserialize!Contact(json);

    c.phone_number.assertEquals("+123456789");
    c.user_id.assertEquals(42);
}

// TODO Add Nullable fields
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
    Nullable!string   foursquare_id;
    Nullable!string   foursquare_type;
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
struct ResponseParameters
{
    long migrate_to_chat_id;
    uint retry_after;
}

alias InputMediaStructs = AliasSeq!(
    InputMediaPhoto,
    InputMediaVideo,
    InputMediaAnimation,
    InputMediaAudio,
    InputMediaDocument
);

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

struct InputMediaAnimation
{
    string type = "animation";
    string media;
    Nullable!string thumb; // TODO InputFile
    Nullable!string caption;
    Nullable!ParseMode parse_mode;
    Nullable!uint width;
    Nullable!uint height;
    Nullable!uint duration;
}

struct InputMediaAudio
{
    string type = "audio";
    string media;
    Nullable!string thumb; // TODO InputFile
    Nullable!string caption;
    Nullable!ParseMode parse_mode;
    Nullable!uint duration;
    Nullable!string performer;
    Nullable!string title;
}

struct InputMediaDocument
{
    string type = "document";
    string media;
    Nullable!string thumb; // TODO InputFile
    Nullable!string caption;
    Nullable!ParseMode parse_mode;
}

struct InputFile
{
    // no fields
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

/// outgoing
struct InputVenueMessageContent
{
    float  latitude;
    float  longitude;
    string title;
    string address;
    Nullable!string foursquare_id;
    Nullable!string foursquare_type;
}

unittest
{
    InputVenueMessageContent ivmc = {
        latitude : 0.01,
        longitude : 0.02,
        title : "t",
        address : "a",
        foursquare_id : "fid",
        foursquare_type : "ft"
    };

    ivmc.serializeToJsonString()
        .assertEquals(
        `{"latitude":0.01,"longitude":0.02,"title":"t","address":"a","foursquare_id":"fid","foursquare_type":"ft"}`
        );
}

struct InputContactMessageContent
{
    string phone_number;
    string first_name;
    Nullable!string last_name;
    Nullable!string vcard;
}

struct ChosenInlineResult
{
    string   result_id;
    User     from;
    Nullable!Location location;
    Nullable!string   inline_message_id;
    string   query;
}

/******************************************************************/
/*                        Telegram methods                        */
/******************************************************************/

@serializedAs!(SerializableEnumProxy!UpdateType)
enum UpdateType: string
{
    Message = "message",
    EditedMessage = "edited_message",
    ChannelPost = "channel_post",
    EditedChannelPost = "edited_channel_post",
    InlineQuery = "inline_query",
    ChosenInlineResult = "chosen_inline_result",
    CallbackQuery = "callback_query",
    ShippingQuery = "shipping_query",
    PreCheckoutQuery = "pre_checkout_query",
    Poll = "poll",
    PollAnswer = "poll_answer"
}

struct GetUpdatesMethod
{
    enum ubyte DEFAULT_LIMIT = 5;
    enum uint DEFAULT_TIMEOUT = 30;

    mixin TelegramMethod!"/getUpdates";

    Nullable!int   offset;
    Nullable!ubyte limit;
    Nullable!uint  timeout;
    Nullable!(UpdateType[]) allowed_updates;

    void updateOffset(uint updateId)
    {
        import std.algorithm.comparison : max;

        if (offset.isNull) {
            offset = updateId + 1;
        } else {
            offset = max(offset.get, updateId) + 1;
        }
    }
}

unittest
{
    GetUpdatesMethod m = {
        offset: 1,
        allowed_updates: [UpdateType.EditedMessage]
    };

    m.serializeToJsonString()
        .assertEquals(`{"offset":1,"allowed_updates":["edited_message"]}`);
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

    m.serializeToJsonString()
        .assertEquals(`{"chat_id":"111","text":"Message text"}`);
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
    Nullable!string      caption;
    Nullable!ParseMode   parse_mode;
    Nullable!bool        disable_notification;
    Nullable!uint        reply_to_message_id;
    Nullable!ReplyMarkup reply_markup;
}

unittest
{
    SendPhotoMethod m = {
        chat_id: "111",
        photo: "Photo url"
    };

    import std.stdio;

    m.serializeToJsonString().writeln;

    m.serializeToJsonString()
        .assertEquals(`{"chat_id":"111","photo":"Photo url"}`);
}
unittest
{
    SendPhotoMethod m = {
        chat_id: "111",
        photo: "Photo url",
        disable_notification: false,
        reply_to_message_id: 0
    };

    m.serializeToJsonString()
        .assertEquals(`{"chat_id":"111","photo":"Photo url","disable_notification":false,"reply_to_message_id":0}`);
}

struct SendAudioMethod
{
    mixin TelegramMethod!"/sendAudio";

    ChatId      chat_id;
    string      audio;
    Nullable!string      caption;
    Nullable!ParseMode   parse_mode;
    Nullable!uint        duration;
    Nullable!string      performer;
    Nullable!string      title;
    Nullable!bool        disable_notification;
    Nullable!uint        reply_to_message_id;
    Nullable!ReplyMarkup reply_markup;

}

unittest
{
    SendAudioMethod m = {
        chat_id: "111",
        audio: "data"
    };

    m.serializeToJsonString()
        .assertEquals(`{"chat_id":"111","audio":"data"}`);
}

unittest
{
    SendAudioMethod m = {
        chat_id: "111",
        audio: "data",
        duration: 0,
        disable_notification:false,
        reply_to_message_id: 0,
    };

    m.serializeToJsonString()
        .assertEquals(
            `{"chat_id":"111","audio":"data","duration":0,"disable_notification":false,"reply_to_message_id":0}`
        );
}

struct SendDocumentMethod
{
    mixin TelegramMethod!"/sendDocument";

    ChatId      chat_id;
    string      document;
    Nullable!string      caption;
    Nullable!ParseMode   parse_mode;
    Nullable!bool        disable_notification;
    Nullable!uint        reply_to_message_id;
    Nullable!ReplyMarkup reply_markup;
}

unittest
{
    SendDocumentMethod m = {
        chat_id: "111",
        document: "data"
    };

    m.serializeToJsonString()
        .assertEquals(`{"chat_id":"111","document":"data"}`);
}

unittest
{
    SendDocumentMethod m = {
        chat_id: "111",
        document: "data",
        disable_notification: false,
        reply_to_message_id: 0,
    };

    m.serializeToJsonString()
        .assertEquals(`{"chat_id":"111","document":"data","disable_notification":false,"reply_to_message_id":0}`);
}

struct SendVideoMethod
{
    mixin TelegramMethod!"/sendVideo";

    string      chat_id;
    string      video;
    Nullable!uint        duration;
    Nullable!uint        width;
    Nullable!uint        height;
    Nullable!string      caption;
    Nullable!ParseMode   parse_mode;
    Nullable!bool        supports_streaming;
    Nullable!bool        disable_notification;
    Nullable!uint        reply_to_message_id;
    Nullable!ReplyMarkup reply_markup;
}

unittest
{
    SendVideoMethod m = {
        chat_id: "111",
        video: "data"
    };

    m.serializeToJsonString()
        .assertEquals(`{"chat_id":"111","video":"data"}`);
}

unittest
{
    SendVideoMethod m = {
        chat_id: "111",
        video: "data",
        duration: 0,
        width: 0,
        height: 0,
        supports_streaming: false,
        disable_notification: false,
        reply_to_message_id: 0
    };

    m.serializeToJsonString()
        .assertEquals(
            `{"chat_id":"111","video":"data","duration":0,"width":0,"height":0,"supports_streaming":false,` ~
            `"disable_notification":false,"reply_to_message_id":0}`
        );
}

struct SendVoiceMethod
{
    mixin TelegramMethod!"/sendVoice";

    ChatId      chat_id;
    string      voice;
    Nullable!string      caption;
    Nullable!ParseMode   parse_mode;
    Nullable!uint        duration;
    Nullable!bool        disable_notification;
    Nullable!uint        reply_to_message_id;
    Nullable!ReplyMarkup reply_markup;
}

unittest
{
    SendVoiceMethod m = {
        chat_id: "111",
        voice: "data"
    };

    m.serializeToJsonString()
        .assertEquals(`{"chat_id":"111","voice":"data"}`);
}

unittest
{
    SendVoiceMethod m = {
        chat_id: "111",
        voice: "data",
        duration: 0,
        disable_notification: false,
        reply_to_message_id: 0,
    };

    m.serializeToJsonString()
        .assertEquals(
            `{"chat_id":"111","voice":"data","duration":0,"disable_notification":false,"reply_to_message_id":0}`
        );
}

struct SendVideoNoteMethod
{
    mixin TelegramMethod!"/sendVideoNote";

    ChatId      chat_id;
    string      video_note;
    Nullable!uint        duration;
    Nullable!uint        length;
    Nullable!bool        disable_notification;
    Nullable!uint        reply_to_message_id;
    Nullable!ReplyMarkup reply_markup;
}

unittest
{
    SendVideoNoteMethod m = {
        chat_id: "111",
        video_note: "data"
    };

    m.serializeToJsonString()
        .assertEquals(`{"chat_id":"111","video_note":"data"}`);
}

struct SendMediaGroupMethod
{
    mixin TelegramMethod!"/sendMediaGroup";

    ChatId       chat_id;
    InputMedia[] media;
    Nullable!bool         disable_notification;
    Nullable!uint         reply_to_message_id;
}

unittest
{
    InputMedia im;

    InputMediaPhoto imp = {
        type: "t",
        media: "m"
    };

    im = imp;

    SendMediaGroupMethod m = {
        chat_id: "111",
        media: [im],
    };

    m.serializeToJsonString()
        .assertEquals(`{"chat_id":"111","media":[{"type":"t","media":"m"}]}`);
}

struct SendLocationMethod
{
    mixin TelegramMethod!"/sendLocation";

    ChatId      chat_id;
    float       latitude;
    float       longitude;
    Nullable!uint        live_period;
    Nullable!bool        disable_notification;
    Nullable!uint        reply_to_message_id;
    Nullable!ReplyMarkup reply_markup;
}

unittest
{
    SendLocationMethod m = {
        chat_id: "111",
        latitude: 0.01,
        longitude: 0.02
    };

    m.serializeToJsonString()
        .assertEquals(`{"chat_id":"111","latitude":0.01,"longitude":0.02}`);
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
    Nullable!string      foursquare_id;
    Nullable!string     foursquare_type;
    Nullable!bool        disable_notification;
    Nullable!uint        reply_to_message_id;
    Nullable!ReplyMarkup reply_markup;
}

unittest
{
    SendVenueMethod m = {
        chat_id: "111",
        latitude: 0.01,
        longitude: 0.02,
        title: "t",
        address: "a"
    };

    m.serializeToJsonString()
        .assertEquals(`{"chat_id":"111","latitude":0.01,"longitude":0.02,"title":"t","address":"a"}`);
}

struct SendContactMethod
{
    mixin TelegramMethod!"/sendContact";

    ChatId      chat_id;
    string      phone_number;
    string      first_name;
    Nullable!string      last_name;
    Nullable!string      vcard;
    Nullable!bool        disable_notification;
    Nullable!uint        reply_to_message_id;
    Nullable!ReplyMarkup reply_markup;
}

unittest
{
    SendContactMethod m = {
        chat_id: "111",
        phone_number: "+7123",
        first_name: "fn"
    };

    m.serializeToJsonString()
        .assertEquals(`{"chat_id":"111","phone_number":"+7123","first_name":"fn"}`);
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

struct GetChatMethod
{
    mixin TelegramMethod!("/getChat", HTTPMethod.GET);

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


// API methods

Update[] getUpdates(BotApi api, ref GetUpdatesMethod m)
{
    return api.callMethod!(Update[])(m);
}

Update[] getUpdates(BotApi api, int offset, ubyte limit = 5, uint timeout = 30, UpdateType[] allowedUpdates = [])
{
    GetUpdatesMethod m = {
        offset:  offset,
        limit:   limit,
        timeout: timeout,
        allowed_updates: allowedUpdates.nullable
    };

    return api.getUpdates(m);
}

User getMe(BotApi api)
{
    GetMeMethod m;

    return api.callMethod!(User, GetMeMethod)(m);
}

Message sendMessage(BotApi api, ref SendMessageMethod m)
{
    return api.callMethod!(Message, SendMessageMethod)(m);
}

Message sendMessage(T)(BotApi api, T chatId, string text)
    if (isTelegramId!T)
{
    SendMessageMethod m = {
        chat_id    : chatId,
        text       : text,
    };

    return sendMessage(api, m);
}

Message forwardMessage(T1, T2)(BotApi api, T1 chatId, T2 fromChatId, uint messageId)
    if (isTelegramId!T1 && isTelegramId!T2)
{
    ForwardMessageMethod m = {
        message_id : messageId,
        chat_id : chatId,
        from_chat_id: fromChatId,
    };

    return api.callMethod!(Message, ForwardMessageMethod)(m);
}

Message forwardMessage(BotApi api, ref ForwardMessageMethod m)
{
    return api.callMethod!(Message, ForwardMessageMethod)(m);
}

Message sendPhoto(BotApi api, ref SendPhotoMethod m)
{
    return api.callMethod!(Message, SendPhotoMethod)(m);
}

Message sendPhoto(T1)(BotApi api, T1 chatId, string photo)
    if (isTelegramId!T1)
{
    SendPhotoMethod m = {
        chat_id : chatId,
        photo : photo,
    };

    return sendPhoto(api, m);
}

Message sendAudio(BotApi api, ref SendAudioMethod m)
{
    return api.callMethod!(Message, SendAudioMethod)(m);
}

Message sendAudio(T1)(BotApi api, T1 chatId, string audio)
    if (isTelegramId!T1)
{
    SendAudioMethod m = {
        chat_id : chatId,
        audio : audio
    };

    return sendAudio(api, m);
}

Message sendDocument(BotApi api, ref SendDocumentMethod m)
{
    return api.callMethod!(Message, SendDocumentMethod)(m);
}

Message sendDocument(T1)(BotApi api, T1 chatId, string document)
    if (isTelegramId!T1)
{
    SendDocumentMethod m = {
        chat_id : chatId,
        document : document
    };

    return sendDocument(api, m);
}

Message sendVideo(BotApi api, ref SendVideoMethod m)
{
    return api.callMethod!(Message, SendVideoMethod)(m);
}

Message sendVideo(T1)(BotApi api, T1 chatId, string video)
    if (isTelegramId!T1)
{
    SendVideoMethod m = {
        chat_id : chatId,
        video : video
    };

    return sendVideo(api, m);
}

Message sendVoice(BotApi api, ref SendVoiceMethod m)
{
    return api.callMethod!(Message, SendVoiceMethod)(m);
}

Message sendVoice(T1)(BotApi api, T1 chatId, string voice)
    if (isTelegramId!T1)
{
    SendVoiceMethod m = {
        chat_id : chatId,
        voice : voice
    };

    return sendVoice(api, m);
}

Message sendVideoNote(BotApi api, ref SendVideoNoteMethod m)
{
    return api.callMethod!(Message, SendVideoNoteMethod)(m);
}

Message sendVideoNote(T1)(BotApi api, T1 chatId, string videoNote)
    if (isTelegramId!T1)
{
    SendVideoNoteMethod m = {
        chat_id : chatId,
        video_note : videoNote
    };

    return sendVideoNote(api, m);
}

Message sendMediaGroup(BotApi api, ref SendMediaGroupMethod m)
{
    return api.callMethod!(Message, SendMediaGroupMethod)(m);
}

Message sendMediaGroup(T1)(BotApi api, T1 chatId, InputMedia[] media)
    if (isTelegramId!T1)
{
    SendMediaGroupMethod m = {
        chat_id : chatId,
        media : media
    };

    return sendMediaGroup(api, m);
}

Message sendLocation(BotApi api, ref SendLocationMethod m)
{
    return api.callMethod!(Message, SendLocationMethod)(m);
}

Message sendLocation(T1)(BotApi api, T1 chatId, float latitude, float longitude)
    if (isTelegramId!T1)
{
    SendLocationMethod m = {
        chat_id : chatId,
        latitude : latitude,
        longitude : longitude,
    };

    return sendLocation(api, m);
}

Nullable!Message editMessageLiveLocation(BotApi api, ref EditMessageLiveLocationMethod m)
{
    return api.callMethod!(Nullable!Message, EditMessageLiveLocationMethod)(m);
}

Nullable!Message editMessageLiveLocation(BotApi api, string inlineMessageId, float latitude, float longitude)
{
    EditMessageLiveLocationMethod m = {
        inline_message_id : inlineMessageId,
        latitude : latitude,
        longitude : longitude
    };

    return editMessageLiveLocation(api, m);
}

Nullable!Message editMessageLiveLocation(T1)(BotApi api, T1 chatId, uint messageId, float latitude, float longitude)
    if (isTelegramId!T1)
{
    EditMessageLiveLocationMethod m = {
        chat_id : chatId,
        message_id : messageId,
        latitude : latitude,
        longitude : longitude
    };

    return editMessageLiveLocation(api, m);
}

Nullable!Message stopMessageLiveLocation(BotApi api, ref StopMessageLiveLocationMethod m)
{
    return api.callMethod!(Nullable!Message, StopMessageLiveLocationMethod)(m);
}

Nullable!Message stopMessageLiveLocation(BotApi api, string inlineMessageId)
{
    StopMessageLiveLocationMethod m = {
        inline_message_id : inlineMessageId
    };

    return stopMessageLiveLocation(api, m);
}

Nullable!Message stopMessageLiveLocation(T1)(BotApi api, T1 chatId, uint messageId)
    if (isTelegramId!T1)
{
    StopMessageLiveLocationMethod m = {
        chat_id : chatId,
        message_id : messageId
    };

    return stopMessageLiveLocation(api, m);
}

Message sendVenue(BotApi api, ref SendVenueMethod m)
{
    return api.callMethod!(Message, SendVenueMethod)(m);
}

Message sendVenue(T1)(BotApi api, T1 chatId, float latitude, float longitude,
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

    return sendVenue(api, m);
}

Message sendContact(BotApi api, ref SendContactMethod m)
{
    return api.callMethod!(Message, SendContactMethod)(m);
}

Message sendContact(T1)(BotApi api, T1 chatId, string phone_number, string first_name)
    if (isTelegramId!T1)
{
    SendContactMethod m = {
        chat_id : chatId,
        phone_number : phone_number,
        first_name : first_name
    };

    return sendContact(api, m);
}

bool sendChatAction(BotApi api, ref SendChatActionMethod m)
{
    return api.callMethod!(bool, SendChatActionMethod)(m);
}

bool sendChatAction(T1)(BotApi api, T1 chatId, string action)
    if (isTelegramId!T1)
{
    SendChatActionMethod m = {
        chat_id : chatId,
        action : action
    };

    return sendChatAction(api, m);
}

UserProfilePhotos getUserProfilePhotos(BotApi api, ref GetUserProfilePhotosMethod m)
{
    return api.callMethod!(UserProfilePhotos, GetUserProfilePhotosMethod)(m);
}

UserProfilePhotos getUserProfilePhotos(BotApi api, int userId)
{
    GetUserProfilePhotosMethod m = {
        user_id : userId
    };

    return getUserProfilePhotos(api, m);
}

File getFile(BotApi api, ref GetFileMethod m)
{
    return api.callMethod!(File, GetFileMethod)(m);
}

File getFile(BotApi api, string fileId)
{
    GetFileMethod m = {
        file_id : fileId
    };

    return getFile(api, m);
}



Chat getChat(BotApi api, ref GetChatMethod m)
{
    return api.callMethod!Chat(m);
}

Chat getChat(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    GetChatMethod m = {
        chat_id : chatId,
    };

    return getChat(api, m);
}

bool answerCallbackQuery(BotApi api, ref AnswerCallbackQueryMethod m)
{
    return api.callMethod!bool(m);
}

bool answerCallbackQuery(BotApi api, string callbackQueryId)
{
    AnswerCallbackQueryMethod m = {
        callback_query_id : callbackQueryId
    };

    return answerCallbackQuery(api, m);
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
    api.getChat("chat-id");
    api.answerCallbackQuery("callback-query-id");
}
