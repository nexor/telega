module telega.methods;

import std.traits;
import std.typecons;
import std.conv : to;
import vibe.http.client : HTTPMethod;
import telega.botapi;

mixin template TelegramMethod(string path, HTTPMethod method = HTTPMethod.POST)
{
    package:
        immutable string _path       = path;
        HTTPMethod       _httpMethod = method;
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
}

struct SetWebhookMethod
{
    mixin TelegramMethod!"/setWebhook";

    string             url;
    Nullable!InputFile certificate;
    uint               max_connections;
    string[]           allowed_updates;
}

struct DeleteWebhookMethod
{
    mixin TelegramMethod!"/deleteWebhook";
}

struct GetWebhookInfoMethod
{
    mixin TelegramMethod!("/getWebhookInfo", HTTPMethod.GET);
}

struct GetMeMethod
{
    mixin TelegramMethod!("/getMe", HTTPMethod.GET);
}

struct SendMessageMethod
{
    mixin TelegramMethod!"/sendMessage";

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
    mixin TelegramMethod!"/forwardMessage";

    string chat_id;
    string from_chat_id;
    bool   disable_notification;
    uint   message_id;
}

struct SendPhotoMethod
{
    mixin TelegramMethod!"/sendPhoto";

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
    mixin TelegramMethod!"/sendAudio";

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
    mixin TelegramMethod!"/sendDocument";

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
    mixin TelegramMethod!"/sendVideo";

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
    mixin TelegramMethod!"/sendVoice";

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
    mixin TelegramMethod!"/sendVideoNote";

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
    mixin TelegramMethod!"/sendMediaGroup";

    string       chat_id;
    InputMedia[] media;
    bool         disable_notification;
    uint         reply_to_message_id;
}

struct SendLocationMethod
{
    mixin TelegramMethod!"/sendLocation";

    string      chat_id;
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

    string      chat_id;
    uint        message_id;
    string      inline_message_id;
    float       latitude;
    float       longitude;
    ReplyMarkup reply_markup;
}

struct StopMessageLiveLocationMethod
{
    mixin TelegramMethod!"/stopMessageLiveLocation";

    string      chat_id;
    uint        message_id;
    string      inline_message_id;
    ReplyMarkup reply_markup;
}

struct SendVenueMethod
{
    mixin TelegramMethod!"/sendVenue";

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
    mixin TelegramMethod!"/sendContact";

    string      chat_id;
    string      phone_number;
    string      first_name;
    string      last_name;
    bool        disable_notification;
    uint        reply_to_message_id;
    ReplyMarkup reply_markup;
}

struct SendChatActionMethod
{
    mixin TelegramMethod!"/sendChatAction";

    string chat_id;
    string action; // TODO enum
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

    string chat_id;
    uint   user_id;
    uint   until_date;
}

struct UnbanChatMemberMethod
{
    mixin TelegramMethod!"/unbanChatMember";

    string chat_id;
    uint   user_id;
}

struct RestrictChatMemberMethod
{
    mixin TelegramMethod!"/restrictChatMember";

    string chat_id;
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

struct ExportChatInviteLinkMethod
{
    mixin TelegramMethod!"/exportChatInviteLink";

    string chat_id;
}

struct SetChatPhotoMethod
{
    mixin TelegramMethod!"/setChatPhoto";

    string    chat_id;
    InputFile photo;

}

struct DeleteChatPhotoMethod
{
    mixin TelegramMethod!"/deleteChatPhoto";

    string chat_id;
}

struct SetChatTitleMethod
{
    mixin TelegramMethod!"/setChatTitle";

    string chat_id;
    string title;
}

struct SetChatDescriptionMethod
{
    mixin TelegramMethod!"/setChatDescription";

    string chat_id;
    string description;
}

struct PinChatMessageMethod
{
    mixin TelegramMethod!"/pinChatMessage";

    string chat_id;
    uint   message_id;
    bool   disable_notification;
}

struct UnpinChatMessageMethod
{
    mixin TelegramMethod!"/unpinChatMessage";

    string chat_id;
}

struct LeaveChatMethod
{
    mixin TelegramMethod!"/leaveChat";

    string chat_id;
}

struct GetChatMethod
{
    mixin TelegramMethod!("/getChat", HTTPMethod.GET);

    string chat_id;
}

struct GetChatAdministratorsMethod
{
    mixin TelegramMethod!("/getChatAdministrators", HTTPMethod.GET);

    string chat_id;
}

struct GetChatMembersCountMethod
{
    mixin TelegramMethod!("/getChatMembersCount", HTTPMethod.GET);

    string chat_id;
}

struct GetChatMemberMethod
{
    mixin TelegramMethod!("/getChatMember", HTTPMethod.GET);

    string chat_id;
    uint   user_id;
}

struct SetChatStickerSetMethod
{
    mixin TelegramMethod!"/setChatStickerSet";

    string chat_id;
    string sticker_set_name;
}

struct DeleteChatStickerSetMethod
{
    mixin TelegramMethod!"/deleteChatStickerSet";

    string chat_id;
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

    string      chat_id;
    uint        message_id;
    string      inline_message_id;
    string      text;
    ParseMode   parse_mode;
    bool        disable_web_page_preview;
    ReplyMarkup reply_markup;
}

struct EditMessageCaptionMethod
{
    mixin TelegramMethod!"/editMessageCaptionMethod";

    string      chat_id;
    uint        message_id;
    string      inline_message_id;
    string      caption;
    ParseMode   parse_mode;
    ReplyMarkup reply_markup;
}

struct EditMessageReplyMarkupMethod
{
    mixin TelegramMethod!"/editMessageReplyMarkupMethod";

    string      chat_id;
    uint        message_id;
    string      inline_message_id;
    ReplyMarkup reply_markup;
}

struct DeleteMessageMethod
{
    mixin TelegramMethod!"/deleteMessageMethod";

    string chat_id;
    uint   message_id;
}

struct SendStickerMethod
{
    mixin TelegramMethod!"/sendStickerMethod";

    string      chat_id;
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

Update[] getUpdates(BotApi api, ubyte limit = 5, uint timeout = 30)
{
    GetUpdatesMethod m = {
        offset:  api.maxUpdateId,
        limit:   limit,
        timeout: timeout,
    };

    return api.callMethod!(Update[], GetUpdatesMethod)(m);
}

bool setWebhook(BotApi api, string url)
{
    SetWebhookMethod m = {
        url : url
    };

    return api.setWebhook(m);
}

bool setWebhook(BotApi api, ref SetWebhookMethod m)
{
    return api.callMethod!(bool, SetWebhookMethod)(m);
}

bool deleteWebhook(BotApi api)
{
    DeleteWebhookMethod m = DeleteWebhookMethod();

    return api.callMethod!(bool, DeleteWebhookMethod)(m);
}

WebhookInfo getWebhookInfo(BotApi api)
{
    GetWebhookInfoMethod m = GetWebhookInfoMethod();

    return api.callMethod!(WebhookInfo, GetWebhookInfoMethod)(m);
}

User getMe(BotApi api)
{
    GetMeMethod m;

    return api.callMethod!(User, GetMeMethod)(m);
}

Message sendMessage(T)(BotApi api, T chatId, string text)
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

    return api.sendMessage(m);
}

Message sendMessage(BotApi api, ref SendMessageMethod m)
{
    return api.callMethod!(Message, SendMessageMethod)(m);
}

Message forwardMessage(T1, T2)(BotApi api, T1 chatId, T2 fromChatId, uint messageId)
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
        photo : photo
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.sendPhoto(m);
}

Message sendAudio(BotApi api, ref SendAudioMethod m)
{
    return api.callMethod!(Message, SendAudioMethod)(m);
}

Message sendAudio(T1)(BotApi api, T1 chatId, string audio)
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

    return api.sendAudio(m);
}

Message sendDocument(BotApi api, ref SendDocumentMethod m)
{
    return api.callMethod!(Message, SendDocumentMethod)(m);
}

Message sendDocument(T1)(BotApi api, T1 chatId, string document)
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

    return api.sendDocument(m);
}

Message sendVideo(BotApi api, ref SendVideoMethod m)
{
    return api.callMethod!(Message, SendVideoMethod)(m);
}

Message sendVideo(T1)(BotApi api, T1 chatId, string video)
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

    return api.sendVideo(m);
}

Message sendVoice(BotApi api, ref SendVoiceMethod m)
{
    return api.callMethod!(Message, SendVoiceMethod)(m);
}

Message sendVoice(T1)(BotApi api, T1 chatId, string voice)
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

    return api.sendVoice(m);
}

Message sendVideoNote(BotApi api, ref SendVideoNoteMethod m)
{
    return api.callMethod!(Message, SendVideoNoteMethod)(m);
}

Message sendVideoNote(T1)(BotApi api, T1 chatId, string videoNote)
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

    return api.sendVideoNote(m);
}

Message sendMediaGroup(BotApi api, ref SendMediaGroupMethod m)
{
    return api.callMethod!(Message, SendMediaGroupMethod)(m);
}

Message sendMediaGroup(T1)(BotApi api, T1 chatId, InputMedia[] media)
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

    return api.sendMediaGroup(m);
}

Message sendLocation(BotApi api, ref SendLocationMethod m)
{
    return api.callMethod!(Message, SendLocationMethod)(m);
}

Message sendLocation(T1)(BotApi api, T1 chatId, float latitude, float longitude)
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

    return api.sendLocation(m);
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

    return api.editMessageLiveLocation(m);
}

Nullable!Message editMessageLiveLocation(T1)(BotApi api, T1 chatId, uint messageId, float latitude, float longitude)
    if (isTelegramId!T1)
{
    EditMessageLiveLocationMethod m = {
        message_id : messageId,
        latitude : latitude,
        longitude : longitude
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.editMessageLiveLocation(m);
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

    return api.stopMessageLiveLocation(m);
}

Nullable!Message stopMessageLiveLocation(T1)(BotApi api, T1 chatId, uint messageId)
    if (isTelegramId!T1)
{
    StopMessageLiveLocationMethod m = {
        message_id : messageId
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.stopMessageLiveLocation(m);
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
        latitude : latitude,
        longitude : longitude,
        title : title,
        address : address
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.sendVenue(m);
}

Message sendContact(BotApi api, ref SendContactMethod m)
{
    return api.callMethod!(Message, SendContactMethod)(m);
}

Message sendContact(T1)(BotApi api, T1 chatId, string phone_number, string first_name)
    if (isTelegramId!T1)
{
    SendContactMethod m = {
        phone_number : phone_number,
        first_name : first_name
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.sendContact(m);
}

bool sendChatAction(BotApi api, ref SendChatActionMethod m)
{
    return api.callMethod!(bool, SendChatActionMethod)(m);
}

bool sendChatAction(T1)(BotApi api, T1 chatId, string action)
    if (isTelegramId!T1)
{
    SendChatActionMethod m = {
        action : action
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.sendChatAction(m);
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

    return api.getUserProfilePhotos(m);
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

    return api.getFile(m);
}

bool kickChatMember(BotApi api, ref KickChatMemberMethod m)
{
    return api.callMethod!(bool, KickChatMemberMethod)(m);
}

bool kickChatMember(T1)(BotApi api, T1 chatId, int userId)
    if(isTelegramId!T1)
{
    KickChatMemberMethod m = {
        user_id : userId
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.kickChatMember(m);
}

bool unbanChatMember(BotApi api, ref UnbanChatMemberMethod m)
{
    return api.callMethod!(bool, UnbanChatMemberMethod)(m);
}

bool unbanChatMember(T1)(BotApi api, T1 chatId, int userId)
    if(isTelegramId!T1)
{
    UnbanChatMemberMethod m = {
        user_id : userId
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.unbanChatMember(m);
}

bool restrictChatMember(BotApi api, ref RestrictChatMemberMethod m)
{
    return api.callMethod!bool(m);
}

bool restrictChatMember(T1)(BotApi api, T1 chatId, int userId)
    if(isTelegramId!T1)
{
    RestrictChatMemberMethod m = {
        user_id : userId
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.restrictChatMember(m);
}

bool promoteChatMember(BotApi api, ref PromoteChatMemberMethod m)
{
    return api.callMethod!bool(m);
}

bool promoteChatMember(T1)(BotApi api, T1 chatId, int userId)
    if(isTelegramId!T1)
{
    PromoteChatMemberMethod m = {
        user_id : userId
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.promoteChatMember(m);
}

string exportChatInviteLink(BotApi api, ref ExportChatInviteLinkMethod m)
{
    return api.callMethod!string(m);
}

string exportChatInviteLink(T1)(BotApi api, T1 chatId)
    if(isTelegramId!T1)
{
    ExportChatInviteLinkMethod m;

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.exportChatInviteLink(m);
}

bool setChatPhoto(BotApi api, ref SetChatPhotoMethod m)
{
    return api.callMethod!bool(m);
}

bool setChatPhoto(T1)(BotApi api, T1 chatId, InputFile photo)
    if (isTelegramId!T1)
{
    SetChatPhotoMethod m = {
        photo : photo
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.setChatPhoto(m);
}

bool deleteChatPhoto(BotApi api, ref DeleteChatPhotoMethod m)
{
    return api.callMethod!bool(m);
}

bool deleteChatPhoto(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    DeleteChatPhotoMethod m;

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.deleteChatPhoto(m);
}

bool setChatTitle(BotApi api, ref SetChatTitleMethod m)
{
    return api.callMethod!bool(m);
}

bool setChatTitle(T1)(BotApi api, T1 chatId, string title)
    if (isTelegramId!T1)
{
    SetChatTitleMethod m = {
        title : title
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.setChatTitle(m);
}

bool setChatDescription(BotApi api, ref SetChatDescriptionMethod m)
{
    return api.callMethod!bool(m);
}

bool setChatDescription(T1)(BotApi api, T1 chatId, string description)
    if (isTelegramId!T1)
{
    SetChatDescriptionMethod m = {
        description : description
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.setChatDescription(m);
}

bool pinChatMessage(BotApi api, ref PinChatMessageMethod m)
{
    return api.callMethod!bool(m);
}

bool pinChatMessage(T1)(BotApi api, T1 chatId, uint messageId)
    if (isTelegramId!T1)
{
    PinChatMessageMethod m = {
        message_id : messageId
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.pinChatMessage(m);
}

bool unpinChatMessage(BotApi api, ref UnpinChatMessageMethod m)
{
    return api.callMethod!bool(m);
}

bool unpinChatMessage(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    UnpinChatMessageMethod m;

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.unpinChatMessage(m);
}

bool leaveChat(BotApi api, ref LeaveChatMethod m)
{
    return api.callMethod!bool(m);
}

bool leaveChat(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    LeaveChatMethod m;

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.leaveChat(m);
}

Chat getChat(BotApi api, ref GetChatMethod m)
{
    return api.callMethod!Chat(m);
}

Chat getChat(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    GetChatMethod m;

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.getChat(m);
}

ChatMember getChatAdministrators(BotApi api, ref GetChatAdministratorsMethod m)
{
    return api.callMethod!ChatMember(m);
}

ChatMember getChatAdministrators(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    GetChatAdministratorsMethod m;

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.getChatAdministrators(m);
}

uint getChatMembersCount(BotApi api, ref GetChatMembersCountMethod m)
{
    return api.callMethod!uint(m);
}

uint getChatMembersCount(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    GetChatMembersCountMethod m;

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.getChatMembersCount(m);
}

ChatMember getChatMember(BotApi api, ref GetChatMemberMethod m)
{
    return api.callMethod!ChatMember(m);
}

ChatMember getChatMember(T1)(BotApi api, T1 chatId, int userId)
    if (isTelegramId!T1)
{
    GetChatMemberMethod m = {
        user_id : userId
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.getChatMember(m);
}

bool setChatStickerSet(BotApi api, ref SetChatStickerSetMethod m)
{
    return api.callMethod!bool(m);
}

bool setChatStickerSet(T1)(BotApi api, T1 chatId, string stickerSetName)
    if (isTelegramId!T1)
{
    SetChatStickerSetMethod m = {
        sticker_set_name : stickerSetName
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.setChatStickerSet(m);
}

bool deleteChatStickerSet(BotApi api, ref DeleteChatStickerSetMethod m)
{
    return api.callMethod!bool(m);
}

bool deleteChatStickerSet(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    DeleteChatStickerSetMethod m;

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.deleteChatStickerSet(m);
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

    return api.answerCallbackQuery(m);
}

bool editMessageText(BotApi api, ref EditMessageTextMethod m)
{
    return api.callMethod!bool(m);
}

bool editMessageText(T1)(BotApi api, T1 chatId, uint messageId, string text)
    if (isTelegramId!T1)
{
    EditMessageTextMethod m = {
        message_id : messageId,
        text : text
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.editMessageText(m);
}

bool editMessageText(BotApi api, string inlineMessageId, string text)
{
    EditMessageTextMethod m = {
        inline_message_id : inlineMessageId,
        text : text
    };

    return api.editMessageText(m);
}

bool editMessageCaption(BotApi api, ref EditMessageCaptionMethod m)
{
    return api.callMethod!bool(m);
}

bool editMessageCaption(T1)(BotApi api, T1 chatId, uint messageId, string caption = null)
    if (isTelegramId!T1)
{
    EditMessageCaptionMethod m = {
        message_id : messageId,
        caption : caption
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.editMessageCaption(m);
}

bool editMessageCaption(BotApi api, string inlineMessageId, string caption = null)
{
    EditMessageCaptionMethod m = {
        inline_message_id : inlineMessageId,
        caption : caption
    };

    return api.editMessageCaption(m);
}

bool editMessageReplyMarkup(BotApi api, ref EditMessageReplyMarkupMethod m)
{
    return api.callMethod!bool(m);
}

bool editMessageReplyMarkup(T1, T2)(BotApi api, T1 chatId, uint messageId, T2 replyMarkup)
    if (isTelegramId!T1 && isReplyMarkup!T2)
{
    EditMessageReplyMarkupMethod m = {
        message_id : messageId
    };

    m.reply_markup = replyMarkup;

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.editMessageReplyMarkup(m);
}

bool editMessageReplyMarkup(BotApi api, string inlineMessageId, Nullable!ReplyMarkup replyMarkup)
{
    EditMessageReplyMarkupMethod m = {
        inline_message_id : inlineMessageId,
        reply_markup : replyMarkup
    };

    return api.editMessageReplyMarkup(m);
}

bool deleteMessage(BotApi api, ref DeleteMessageMethod m)
{
    return api.callMethod!bool(m);
}

bool deleteMessage(T1)(BotApi api, T1 chatId, uint messageId)
    if (isTelegramId!T1)
{
    DeleteMessageMethod m = {
        message_id : messageId
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.deleteMessage(m);
}

Message sendSticker(BotApi api, ref SendStickerMethod m)
{
    return api.callMethod!Message(m);
}

// TODO sticker is InputFile|string
Message sendSticker(T1)(BotApi api, T1 chatId, string sticker)
    if (isTelegramId!T1)
{
    SendStickerMethod m = {
        sticker : sticker
    };

    static if (isIntegral!T1) {
        m.chat_id = chatId.to!string;
    } else {
        m.chat_id = chatId;
    }

    return api.sendSticker(m);
}

StickerSet getStickerSet(BotApi api, ref GetStickerSetMethod m)
{
    return api.callMethod!StickerSet(m);
}

StickerSet getStickerSet(BotApi api, string name)
{
    GetStickerSetMethod m = {
        name : name
    };

    return api.getStickerSet(m);
}

File uploadStickerFile(BotApi api, ref UploadStickerFileMethod m)
{
    return api.callMethod!File(m);
}

File uploadStickerFile(BotApi api, int userId, InputFile pngSticker)
{
    UploadStickerFileMethod m = {
        user_id : userId,
        png_sticker : pngSticker
    };

    return api.uploadStickerFile(m);
}

bool createNewStickerSet(BotApi api, ref CreateNewStickerSetMethod m)
{
    return api.callMethod!bool(m);
}

// TODO pngSticker is InputFile|string
bool createNewStickerSet(BotApi api, int userId, string name, string title, string pngSticker, string emojis)
{
    CreateNewStickerSetMethod m = {
        user_id : userId,
        name : name,
        title : title,
        png_sticker : pngSticker,
        emojis : emojis
    };

    return api.createNewStickerSet(m);
}

bool addStickerToSet(BotApi api, ref AddStickerToSetMethod m)
{
    return api.callMethod!bool(m);
}

bool addStickerToSet(BotApi api, int userId, string name, string pngSticker, string emojis)
{
    AddStickerToSetMethod m = {
        user_id : userId,
        name : name,
        png_sticker : pngSticker,
        emojis : emojis
    };

    return api.addStickerToSet(m);
}

bool setStickerPositionInSet(BotApi api, ref SetStickerPositionInSetMethod m)
{
    return api.callMethod!bool(m);
}

bool setStickerPositionInSet(BotApi api, string sticker, uint position)
{
    SetStickerPositionInSetMethod m = {
        sticker : sticker,
        position : position
    };

    return api.setStickerPositionInSet(m);
}

bool deleteStickerFromSet(BotApi api, ref DeleteStickerFromSetMethod m)
{
    return api.callMethod!bool(m);
}

bool deleteStickerFromSet(BotApi api, string sticker)
{
    DeleteStickerFromSetMethod m = {
        sticker : sticker
    };

    return api.deleteStickerFromSet(m);
}

bool answerInlineQuery(BotApi api, ref AnswerInlineQueryMethod m)
{
    return api.callMethod!bool(m);
}

bool answerInlineQuery(BotApi api, string inlineQueryId, InlineQueryResult[] results)
{
    AnswerInlineQueryMethod m = {
        inline_query_id : inlineQueryId,
        results : results
    };

    return api.answerInlineQuery(m);
}

unittest
{
    class BotApiMock : BotApi
    {
        this(string token)
        {
            super(token);
        }
    }

    auto api = new BotApiMock("");

    api.getUpdates(5,30);
    api.setWebhook("https://webhook.url");
    api.deleteWebhook();
    api.getWebhookInfo();
    api.getMe();
    api.sendMessage("chat-id", "hello");
    api.sendMessage(42, "hello");
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