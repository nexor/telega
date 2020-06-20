# Telega
[Telegram bot API](https://core.telegram.org/bots/api) implementation.

[![Dub version](https://img.shields.io/dub/v/telega.svg)](http://code.dlang.org/packages/telega)
[![Build Status](https://travis-ci.org/nexor/telega.svg?branch=master)](https://travis-ci.org/nexor/telega)

## Quickstart

Simple echo bot example

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
You can find some examples in the [examples dir](examples/)

API types and methods can be found in telega.telegram.* modules.

Each method is typically implemented using 3 constructs:
 - structure for the method fully describing its signature;
 - a function that accepts a few arguments representing required method arguments
 - a function that accepts a reference to a method struct for calling method with required and optional arguments

For example:
```d
// full method structure
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

// short form
Message sendMessage(BotApi api, ref SendMessageMethod m)

// full form
Message sendMessage(T)(BotApi api, T chatId, string text) if (isTelegramId!T)
```

### Some hints
`ChatId` type is actually `long` or `string`

`isTelegramId!T` template checks `T` to be some string or number

### Support
[Issues](https://github.com/nexor/telega/issues) and PR's are welcome.
