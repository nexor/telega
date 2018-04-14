# Telega
Telegram bot API implementation.

[![Build Status](https://travis-ci.org/nexor/telega.svg?branch=master)](https://travis-ci.org/nexor/telega)

## Implemented features

### Methods

getUpdates, getMe, sendMessage, forwardMessage

**TBD:** setWebhook, deleteWebhook, getWebhookInfo,
sendPhoto, sendAudio, sendDocument, sendVideo,
sendVoice, sendVideoNote, sendMediaGroup, sendLocation,
editMessageLiveLocation, stopMessageLiveLocation, sendVenue, sendContact,
sendChatAction, getUserProfilePhotos, getFile, kickChatMember,
unbanChatMember, restrictChatMember, promoteChatMember, exportChatInviteLink,
setChatPhoto, deleteChatPhoto, setChatTitle, setChatDescription,
pinChatMessage, unpinChatMessage, leaveChat, getChat,
getChatAdministrators, getChatMembersCount, getChatMember,
setChatStickerSet, deleteChatStickerSet, answerCallbackQuery.

**TBD additional:** sending files, inline mode, payments, games, webhook mode

### Types

Update, User, Chat, Message(partially), PhotoSize

**TBD:** Message, MessageEntity, Audio, Document, Video, Voice,
VideoNote, Contact, Location, Venue, UserProfilePhotos, File,
ReplyKeyboardMarkup, KeyboardButton, ReplyKeyboardRemove,
InlineKeyboardMarkup, InlineKeyboardButton, CallbackQuery,
ForceReply, ChatPhoto, ChatMember, ResponseParameters, InputMedia,
InputMediaPhoto, InputMediaVideo, InputFile

**TBD inline types:** InlineQuery, InlineQueryResult, InlineQueryResultArticle,
InlineQueryResultPhoto, InlineQueryResultGif, InlineQueryResultMpeg4Gif,
InlineQueryResultVideo, InlineQueryResultAudio, InlineQueryResultVoice,
InlineQueryResultDocument, InlineQueryResultLocation, InlineQueryResultVenue,
InlineQueryResultContact, InlineQueryResultGame, InlineQueryResultCachedPhoto,
InlineQueryResultCachedGif, InlineQueryResultCachedMpeg4Gif,
InlineQueryResultCachedSticker, InlineQueryResultCachedDocument,
InlineQueryResultCachedVideo, InlineQueryResultCachedVoice,
InlineQueryResultCachedAudio, InputMessageContent, InputTextMessageContent,
InputLocationMessageContent, InputVenueMessageContent, InputContactMessageContent,
ChosenInlineResult
