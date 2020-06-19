# Telega
Telegram bot API implementation.

[![Dub version](https://img.shields.io/dub/v/telega.svg)](http://code.dlang.org/packages/telega)
[![Build Status](https://travis-ci.org/nexor/telega.svg?branch=master)](https://travis-ci.org/nexor/telega)

## Implemented features

### Methods

setWebhook, deleteWebhook, getWebhookInfo,
getUpdates, getMe, sendMessage, forwardMessage, sendPhoto, sendAudio
sendDocument, sendVideo, sendVoice, sendVideoNote, sendMediaGroup,
sendLocation, editMessageLiveLocation, stopMessageLiveLocation, sendVenue, sendContact, sendChatAction, getUserProfilePhotos, getFile, kickChatMember,
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
