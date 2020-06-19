import vibe.core.core;
import vibe.core.log;
import std.typecons;

string botToken = "";

int main(string[] args)
{
    if (args.length > 1 && args[1] != null) {
        logInfo("Setting token from first argument");
        botToken = args[1];
    } else {
        logError("Please provide bot token as a first argument");

        return 1;
    }

    setLogLevel(LogLevel.diagnostic);

    runTask(&listenUpdates);

    return runApplication();
}

void listenUpdates()
{
    import telega.botapi : BotApi;
    import telega.telegram.basic : Update, sendMessage;
    import telega.helpers : UpdatesRange;

    try {
        auto api = new BotApi(botToken);

        foreach (Update update; new UpdatesRange(api, 0)) {
            if (!update.message.isNull && !update.message.text.isNull) {
                logInfo("Text from %s: %s", update.message.chat.id, update.message.text);
                api.sendMessage(update.message.chat.id, update.message.text);
            }
        }
    } catch (Exception e) {
        logError(e.toString());

        throw e;
    }
}
