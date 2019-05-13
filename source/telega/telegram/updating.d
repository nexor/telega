module telega.telegram.updating;

import std.typecons;
import telega.botapi;
import telega.serialization;

/******************************************************************/
/*                             Methods                            */
/******************************************************************/

struct EditMessageMediaMethod
{
    mixin TelegramMethod!"/editMessageMedia";

    Nullable!ChatId chat_id;
    Nullable!uint        message_id;
    Nullable!string      inline_message_id;

    InputMedia media;
    ReplyMarkup reply_markup;
}

/* TODO return bool OR Message*/
bool editMessageMedia(BotApi api, ref EditMessageMediaMethod m)
{
    return api.callMethod!(bool, EditMessageMediaMethod)(m);
}
