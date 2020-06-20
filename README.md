# Telega
Telegram bot API implementation.

[![Dub version](https://img.shields.io/dub/v/telega.svg)](http://code.dlang.org/packages/telega)
[![Build Status](https://travis-ci.org/nexor/telega.svg?branch=master)](https://travis-ci.org/nexor/telega)

## Quickstart

Simple example of echobot

```d
import vibe.core.core : runApplication, runTask;
import vibe.core.log : setLogLevel, logInfo, LogLevel;
import std.process : environment;
import std.exception : enforce;

int main(string[] args)
{
    string botToken = environment.get("BOT_TOKEN");

    if (args.length > 1 && args[1] != null) {
        logInfo("Setting token from first argument");
        botToken = args[1];
    }

    enforce(botToken !is null, "Please provide bot token as a first argument or set BOT_TOKEN env variable");

    setLogLevel(LogLevel.diagnostic);
    runTask(&listenUpdates, botToken);

    return runApplication();
}

void listenUpdates(string token)
{
    import telega.botapi : BotApi;
    import telega.telegram.basic : Update, getUpdates, sendMessage;
    import std.algorithm.iteration : filter, each;
    import std.algorithm.comparison : max;

    int offset;
    auto api = new BotApi(token);

    while (true)
    {
        api.getUpdates(offset)
            .filter!(u => !u.message.text.isNull) // we need all updates with text message
            .each!((Update u) {
                logInfo("Text from %s: %s", u.message.chat.id, u.message.text);
                api.sendMessage(u.message.chat.id, u.message.text);
                offset = max(offset, u.id)+1;
            });
    }
}
```

## Installation
You can add package to your project using dub:
```
dub add telega
```

## Todo

 - [ ] Sending files
 - [ ] Inline mode
 - [ ] Bot API 4.0
 - [ ] Bot API 4.1 and newer

## Help
You can find some examples in the (examples dir)[examples/]

API types and methods can be found in telega.telegram.* modules.

Each method is typically implemented using 3 constructs:
 - structure for the method fully describing its signature;
 - a function that accepts a few arguments representing required method arguments
 - a function that accepts a reference to a method struct for calling method with required and optional arguments

unbanChatMember, restrictChatMember, promoteChatMember, exportChatInviteLink,
setChatPhoto, deleteChatPhoto, setChatTitle, setChatDescription,
pinChatMessage, unpinChatMessage, leaveChat, getChat,
getChatAdministrators, getChatMembersCount, getChatMember,
setChatStickerSet, deleteChatStickerSet, answerCallbackQuery,
editMessageText, editMessageCaption, editMessageReplyMarkup,
deleteMessage, sendSticker, getStickerSet, uploadStickerFile,
createNewStickerSet, addStickerToSet, setStickerPositionInSet, deleteStickerFromSet

**TBD additional:** sending files, inline mode, payments, games, webhook mode

### Types

Webhook, Update, User, Chat, Message, PhotoSize, MessageEntity, Audio,
Document, Video, Voice,
VideoNote, Contact, Location, Venue, UserProfilePhotos, File,
ReplyKeyboardMarkup, KeyboardButton, ReplyKeyboardRemove,
InlineKeyboardMarkup, InlineKeyboardButton, CallbackQuery,
ForceReply, ChatPhoto, ChatMember, ResponseParameters, InputMedia,
InputMediaPhoto, InputMediaVideo, InputFile, ChosenInlineResult
Sticker, StickerSet, MaskPosition InlineQuery,
all InlineQueryResult* types, all InputMessageContent types
