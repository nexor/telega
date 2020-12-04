module pollbot.pollbot;

import std.typecons : Nullable;
import vibe.core.log : setLogLevel, logInfo, LogLevel;
import telega.telegram.basic : Message, Update, sendMessage;
import telega.telegram.poll : Poll, SendPollMethod, StopPollMethod, sendPoll, stopPoll, PollType;
import telega.botapi : BotApi;

class PollBot
{
    private Nullable!Message currentPoll;
    private BotApi api;

    public this(BotApi api)
    {
        this.api = api;
    }

    public void onUpdate(ref Update u)
    {
        // we need all updates with text message
        if (!u.message.isNull && !u.message.get.text.isNull)
        {
            this.onText(u.message.get);
        }

        if (!u.poll_answer.isNull) {
            logInfo("Poll answer %s", u.poll_answer);
        }
        if (!u.poll.isNull) {
            logInfo("Poll changed");
        }
    }

    private void onText(ref Message m)
    {
        if (m.text == "/poll") {
            logInfo("Starting poll in %s", m.chat.id);

            SendPollMethod sendPoll = {
                chat_id: m.chat.id,
                question: "Send /result to stop this poll",
                is_anonymous: false,
                type: PollType.Quiz,
                correct_option_id: 1,
                allows_multiple_answers: true,
                options: [
                    "option 1",
                    "option 2",
                    "option 3",
                ]
            };
            Message message = api.sendPoll(sendPoll);
            currentPoll = message;

            logInfo("Started poll %s", message.poll.get.id);
        }

        if (m.text == "/result") {
            if (currentPoll.isNull) {
                api.sendMessage(m.chat.id, "No poll was started, send /poll to start a new poll.");

                return;
            }

            Poll pollResult = api.stopPoll(currentPoll.get.chat.id, currentPoll.get.id);
            api.sendMessage(currentPoll.get.chat.id, "Poll results: ");
        }
    }

    private void onNewPoll()
    {

    }

    private void onPollStopped()
    {

    }
}
