module telega.telegram.poll;

import std.typecons : Nullable;
import telega.botapi : BotApi, TelegramMethod, HTTPMethod, ChatId, isTelegramId;
import telega.telegram.basic : Message, MessageEntity, User, ReplyMarkup;
import telega.serialization : SerializableEnumProxy;
import asdf.serialization : serdeProxy;

@serdeProxy!(SerializableEnumProxy!PollType)
enum PollType : string
{
    Quiz = "quiz",
    Regular = "regular"
}

struct PollOption
{
    string text;
    uint voter_count;
}

struct PollAnswer
{
    string poll_id;
    User user;
    uint[] option_ids;
}

struct Poll
{
    string id;
    string question;
    PollOption[] options;
    uint total_voter_count;
    bool is_closed;
    bool is_anonymous;
    string type;
    bool allows_multiple_answers;
    Nullable!uint correct_option_id;
    Nullable!string explanation;
    Nullable!MessageEntity[] explanation_entities;
    Nullable!uint open_period;
    Nullable!uint close_date;
}

struct SendPollMethod
{
    mixin TelegramMethod!"/sendPoll";

    ChatId chat_id;
    string question;
    string[] options;
    Nullable!bool is_anonymous;
    Nullable!PollType type;
    Nullable!bool allows_multiple_answers;
    Nullable!uint correct_option_id;
    Nullable!string explanation;
    Nullable!string explanation_parse_mode;
    Nullable!ushort open_period;
    Nullable!uint close_date;
    Nullable!bool is_closed;
    Nullable!bool disable_notification;
    Nullable!uint reply_to_message_id;
    Nullable!ReplyMarkup reply_markup;
}

struct StopPollMethod
{
    mixin TelegramMethod!"/stopPoll";

    ChatId chat_id;
    uint message_id;
    Nullable!ReplyMarkup reply_markup;
}

Message sendPoll(BotApi api, ref SendPollMethod m)
{
    return api.callMethod!Message(m);
}

Message sendPoll(T1)(BotApi api, T1 chatId, string question, string[] options)
    if (isTelegramId!T1)
{
    SendPollMethod m = {
        chat_id: chatId,
        question: question,
        options: options
    };

    return sendPoll(api, m);
}

Poll stopPoll(BotApi api, ref StopPollMethod m)
{
    return api.callMethod!Poll(m);
}

Poll stopPoll(T1)(BotApi api, T1 chatId, uint messageId)
{
    StopPollMethod m = {
        chat_id: chatId,
        message_id: messageId
    };

    return stopPoll(api, m);
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

    api.sendPoll("chat-id", "question", ["q1", "q2"]);
    api.stopPoll("chat-id", 123);
}
