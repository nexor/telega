module telega.telegram.common;

import std.typecons;
import telega.botapi;
import telega.serialization;

/******************************************************************/
/*                              Types                             */
/******************************************************************/



/******************************************************************/
/*                             Methods                            */
/******************************************************************/

struct SendAnimationMethod
{
    mixin TelegramMethod!"/sendAnimationMethod";

    ChatId chat_id;
    string animation;
    Nullable!uint duration;
    Nullable!uint width;
    Nullable!uint height;
    Nullable!string thumb;
    Nullable!string caption;
    ParseMode parse_mode;
    Nullable!bool disable_notification;
    Nullable!uint reply_to_message_id;
    ReplyMarkup reply_markup;
}

unittest
{
    SendAnimationMethod m = {
        chat_id: 42,
        animation: "animationstring"
    };

    assert(m.serializeToJsonString() ==
        `{"chat_id":"42","animation":"animationstring","parse_mode":"Markdown","reply_markup":"{}"}`);
}

Message sendAnimation(BotApi api, ref SendAnimationMethod m)
{
    return api.callMethod!(Message, SendAnimationMethod)(m);
}

Message sendAnimation(T1)(BotApi api, T1 chatId, string animation)
    if (isTelegramId!T1)
{
    SendAnimationMethod m = {
        chat_id : chatId,
        animation : animation
    };

    return sendAudio(m);
}
