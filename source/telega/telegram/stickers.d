module telega.telegram.stickers;

import telega.botapi : BotApi, TelegramMethod, HTTPMethod, isTelegramId, ChatId,
        PhotoSize, ReplyMarkup, InputFile, Message, File;

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

// methods

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

// API methods
Message sendSticker(BotApi api, ref SendStickerMethod m)
{
    return api.callMethod!Message(m);
}

// TODO sticker is InputFile|string
Message sendSticker(T1)(BotApi api, T1 chatId, string sticker)
    if (isTelegramId!T1)
{
    SendStickerMethod m = {
        chat_id : chatId,
        sticker : sticker
    };

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

bool addStickerToSet(BotApi api,ref AddStickerToSetMethod m)
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

    api.setChatStickerSet("chat-id", "sticker-set");
    api.deleteChatStickerSet("chat-id");

    api.sendSticker("chat-id", "sticker");
    api.getStickerSet("sticker-set");
    api.uploadStickerFile(1, InputFile());
    api.createNewStickerSet(1, "name", "title", "png-sticker", "emojis");
    api.addStickerToSet(1, "name", "png-sticker", "emojis");
    api.setStickerPositionInSet("sticker", 42);
    api.deleteStickerFromSet("sticker");
}
