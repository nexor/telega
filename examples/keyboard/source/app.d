import vibe.core.core;
import vibe.core.log;
import std.typecons;
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
    disableDefaultSignalHandlers();

    return runApplication();
}

void listenUpdates(string botToken)
{
    import telega.botapi : BotApi, ChatId;
    import telega.telegram.basic :
        Update, UpdateType, GetUpdatesMethod, Message, getUpdates, sendMessage, ReplyKeyboardRemove, SendMessageMethod;
    import std.algorithm.iteration : each, filter;

    try {
        import telega.drivers.requests : RequestsHttpClient;

        auto api = new BotApi(botToken);

        GetUpdatesMethod gu = {
            offset: 0,
            limit: GetUpdatesMethod.DEFAULT_LIMIT,
            timeout: GetUpdatesMethod.DEFAULT_TIMEOUT,
            allowed_updates: [UpdateType.Message]
        };

        while (true)
        {
            foreach (ref Update update; api.getUpdates(gu))
            {
                if (!update.message.isNull && !update.message.get.text.isNull)
                {
                    SendMessageMethod sm = {
                        chat_id: update.message.get.chat.id,
                        text: update.message.get.text.get
                    };

                    logInfo("Text from %s: %s", sm.chat_id, sm.text);

                    if (sm.text == "Remove Keyboard") {
                        sm.reply_markup = ReplyKeyboardRemove();
                    } else {
                        sm.reply_markup = createReplyKeyboardMarkup();
                    }

                    api.sendMessage(sm);
                } else {
                    logDiagnostic("Update is not a text message, skipping");
                }

                gu.updateOffset(update.id);
            }
        }
    } catch (Exception e) {
        logError(e.toString());

        throw e;
    }
}

auto createReplyKeyboardMarkup()
{
    import telega.telegram.basic : ReplyKeyboardMarkup, KeyboardButton;

    // create keyboard initialized with one row with 2 buttons
    ReplyKeyboardMarkup markup = ReplyKeyboardMarkup([
        ["First Button", "Second Button"]
    ]);

    // button rows can be appended to a keyboard
    markup ~= [KeyboardButton("Ask location").requestLocation()];
    markup ~= [KeyboardButton("Remove Keyboard")];

    return markup;
}
