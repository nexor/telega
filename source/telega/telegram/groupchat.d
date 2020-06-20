module telega.telegram.groupchat;

import std.typecons : Nullable;
import telega.botapi : BotApi, TelegramMethod, HTTPMethod, ChatId, isTelegramId;
import telega.telegram.basic : User, InputFile;

/******************************************************************/
/*                    Telegram types and enums                    */
/******************************************************************/

struct ChatMember
{
    User   user;
    string status;
    Nullable!uint   until_date;
    Nullable!bool   can_be_edited;
    Nullable!bool   can_change_info;
    Nullable!bool   can_post_messages;
    Nullable!bool   can_edit_messages;
    Nullable!bool   can_delete_messages;
    Nullable!bool   can_invite_users;
    Nullable!bool   can_restrict_members;
    Nullable!bool   can_pin_messages;
    Nullable!bool   can_promote_members;
    Nullable!bool   can_send_messages;
    Nullable!bool   can_send_media_messages;
    Nullable!bool   can_send_other_messages;
    Nullable!bool   can_add_web_page_previews;
}

/******************************************************************/
/*                        Telegram methods                        */
/******************************************************************/

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

bool kickChatMember(BotApi api, ref KickChatMemberMethod m)
{
    return api.callMethod!(bool, KickChatMemberMethod)(m);
}

bool kickChatMember(T1)(BotApi api, T1 chatId, int userId)
    if(isTelegramId!T1)
{
    KickChatMemberMethod m = {
        chat_id : chatId,
        user_id : userId
    };

    return kickChatMember(api, m);
}

bool unbanChatMember(BotApi api, ref UnbanChatMemberMethod m)
{
    return api.callMethod!(bool, UnbanChatMemberMethod)(m);
}

bool unbanChatMember(T1)(BotApi api, T1 chatId, int userId)
    if(isTelegramId!T1)
{
    UnbanChatMemberMethod m = {
        chat_id : chatId,
        user_id : userId
    };

    return unbanChatMember(api, m);
}

bool restrictChatMember(BotApi api, ref RestrictChatMemberMethod m)
{
    return api.callMethod!bool(m);
}

bool restrictChatMember(T1)(BotApi api, T1 chatId, int userId)
    if(isTelegramId!T1)
{
    RestrictChatMemberMethod m = {
        chat_id : chatId,
        user_id : userId
    };

    return restrictChatMember(api, m);
}

bool promoteChatMember(BotApi api, ref PromoteChatMemberMethod m)
{
    return api.callMethod!bool(m);
}

bool promoteChatMember(T1)(BotApi api, T1 chatId, int userId)
    if(isTelegramId!T1)
{
    PromoteChatMemberMethod m = {
        chat_id : chatId,
        user_id : userId
    };

    return promoteChatMember(api, m);
}

string exportChatInviteLink(BotApi api, ref ExportChatInviteLinkMethod m)
{
    return api.callMethod!string(m);
}

string exportChatInviteLink(T1)(BotApi api, T1 chatId)
    if(isTelegramId!T1)
{
    ExportChatInviteLinkMethod m = {
        chat_id : chatId,
    };

    return exportChatInviteLink(api, m);
}

bool setChatPhoto(BotApi api, ref SetChatPhotoMethod m)
{
    return api.callMethod!bool(m);
}

bool setChatPhoto(T1)(BotApi api, T1 chatId, InputFile photo)
    if (isTelegramId!T1)
{
    SetChatPhotoMethod m = {
        chat_id : chatId,
        photo : photo
    };

    return setChatPhoto(api, m);
}

bool deleteChatPhoto(BotApi api, ref DeleteChatPhotoMethod m)
{
    return api.callMethod!bool(m);
}

bool deleteChatPhoto(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    DeleteChatPhotoMethod m = {
        chat_id : chatId,
    };

    return deleteChatPhoto(api, m);
}

bool setChatTitle(BotApi api, ref SetChatTitleMethod m)
{
    return api.callMethod!bool(m);
}

bool setChatTitle(T1)(BotApi api, T1 chatId, string title)
    if (isTelegramId!T1)
{
    SetChatTitleMethod m = {
        chat_id : chatId,
        title : title
    };

    return setChatTitle(api, m);
}

bool setChatDescription(BotApi api, ref SetChatDescriptionMethod m)
{
    return api.callMethod!bool(m);
}

bool setChatDescription(T1)(BotApi api, T1 chatId, string description)
    if (isTelegramId!T1)
{
    SetChatDescriptionMethod m = {
        chat_id : chatId,
        description : description
    };

    return setChatDescription(api, m);
}

bool pinChatMessage(BotApi api, ref PinChatMessageMethod m)
{
    return api.callMethod!bool(m);
}

bool pinChatMessage(T1)(BotApi api, T1 chatId, uint messageId)
    if (isTelegramId!T1)
{
    PinChatMessageMethod m = {
        chat_id : chatId,
        message_id : messageId
    };

    return pinChatMessage(api, m);
}

bool unpinChatMessage(BotApi api, ref UnpinChatMessageMethod m)
{
    return api.callMethod!bool(m);
}

bool unpinChatMessage(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    UnpinChatMessageMethod m = {
        chat_id : chatId,
    };

    return unpinChatMessage(api, m);
}

bool leaveChat(BotApi api, ref LeaveChatMethod m)
{
    return api.callMethod!bool(m);
}

bool leaveChat(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    LeaveChatMethod m = {
        chat_id : chatId,
    };

    return leaveChat(api, m);
}

ChatMember getChatAdministrators(BotApi api, ref GetChatAdministratorsMethod m)
{
    return api.callMethod!ChatMember(m);
}

ChatMember getChatAdministrators(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    GetChatAdministratorsMethod m = {
        chat_id : chatId,
    };

    return getChatAdministrators(api, m);
}

uint getChatMembersCount(BotApi api, ref GetChatMembersCountMethod m)
{
    return api.callMethod!uint(m);
}

uint getChatMembersCount(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    GetChatMembersCountMethod m = {
        chat_id : chatId,
    };

    return getChatMembersCount(api, m);
}

ChatMember getChatMember(BotApi api, ref GetChatMemberMethod m)
{
    return api.callMethod!ChatMember(m);
}

ChatMember getChatMember(T1)(BotApi api, T1 chatId, int userId)
    if (isTelegramId!T1)
{
    GetChatMemberMethod m = {
        chat_id : chatId,
        user_id : userId
    };

    return getChatMember(api, m);
}

bool setChatStickerSet(BotApi api, ref SetChatStickerSetMethod m)
{
    return api.callMethod!bool(m);
}

bool setChatStickerSet(T1)(BotApi api, T1 chatId, string stickerSetName)
    if (isTelegramId!T1)
{
    SetChatStickerSetMethod m = {
        chat_id : chatId,
        sticker_set_name : stickerSetName
    };

    return setChatStickerSet(api, m);
}

bool deleteChatStickerSet(BotApi api, ref DeleteChatStickerSetMethod m)
{
    return api.callMethod!bool(m);
}

bool deleteChatStickerSet(T1)(BotApi api, T1 chatId)
    if (isTelegramId!T1)
{
    DeleteChatStickerSetMethod m = {
        chat_id : chatId,
    };

    return deleteChatStickerSet(api, m);
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
    api.getChatAdministrators("chat-id");
    api.getChatMembersCount("chat-id");
    api.getChatMember("chat-id", 1);
    api.setChatStickerSet("chat-id", "sticker-set");
    api.deleteChatStickerSet("chat-id");
}
