module telega.telegram.updmessages;

import std.typecons : Nullable;
import telega.botapi : BotApi, TelegramMethod, HTTPMethod, ChatId, isTelegramId;
import telega.telegram.basic : ParseMode, ReplyMarkup, ForceReply, ReplyKeyboardMarkup, ReplyKeyboardRemove,
        InlineKeyboardMarkup, isReplyMarkup;

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

bool editMessageText(BotApi api, ref EditMessageTextMethod m)
{
    return api.callMethod!bool(m);
}

bool editMessageText(T1)(BotApi api, T1 chatId, uint messageId, string text)
    if (isTelegramId!T1)
{
    EditMessageTextMethod m = {
        chat_id : chatId,
        message_id : messageId,
        text : text
    };

    return editMessageText(api, m);
}

bool editMessageText(BotApi api, string inlineMessageId, string text)
{
    EditMessageTextMethod m = {
        inline_message_id : inlineMessageId,
        text : text
    };

    return editMessageText(api, m);
}

bool editMessageCaption(BotApi api, ref EditMessageCaptionMethod m)
{
    return api.callMethod!bool(m);
}

bool editMessageCaption(T1)(BotApi api, T1 chatId, uint messageId, string caption = null)
    if (isTelegramId!T1)
{
    EditMessageCaptionMethod m = {
        chat_id : chatId,
        message_id : messageId,
        caption : caption
    };

    return editMessageCaption(api, m);
}

bool editMessageCaption(BotApi api, string inlineMessageId, string caption = null)
{
    EditMessageCaptionMethod m = {
        inline_message_id : inlineMessageId,
        caption : caption
    };

    return editMessageCaption(api, m);
}

bool editMessageReplyMarkup(BotApi api, ref EditMessageReplyMarkupMethod m)
{
    return api.callMethod!bool(m);
}

bool editMessageReplyMarkup(T1, T2)(BotApi api, T1 chatId, uint messageId, T2 replyMarkup)
    if (isTelegramId!T1 && isReplyMarkup!T2)
{
    EditMessageReplyMarkupMethod m = {
        chat_id : chatId,
        message_id : messageId
    };

    m.reply_markup = replyMarkup;

    return editMessageReplyMarkup(api, m);
}

bool editMessageReplyMarkup(BotApi api, string inlineMessageId, Nullable!ReplyMarkup replyMarkup)
{
    EditMessageReplyMarkupMethod m = {
        inline_message_id : inlineMessageId,
        reply_markup : replyMarkup
    };

    return editMessageReplyMarkup(api, m);
}

bool deleteMessage(BotApi api, ref DeleteMessageMethod m)
{
    return api.callMethod!bool(m);
}

bool deleteMessage(T1)(BotApi api, T1 chatId, uint messageId)
    if (isTelegramId!T1)
{
    DeleteMessageMethod m = {
        chat_id : chatId,
        message_id : messageId
    };

    return deleteMessage(api, m);
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
}
