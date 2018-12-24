import vibe.core.core;
import vibe.core.log;
import std.typecons;

string botToken = "123456789:BotTokenHerE";

int main(string[] args)
{
    if (args.length > 1 && args[1] != null) {
        logInfo("Setting token from first argument");
        botToken = args[1];
    }

    setLogLevel(LogLevel.trace);

    runTask(&listenUpdates);

    return runApplication();
}

void listenUpdates()
{
    import telega.botapi;
    import telega.drivers.requests : RequestsHttpClient;

    try {
        auto api = new BotApi(botToken, BaseApiUrl, httpClient);

        while(true) {
            logInfo("Waiting for updates...");
            auto updates = api.getUpdates();
            logInfo("Got %d updates", updates.length);

            foreach (update; updates) {
                if (!update.message.isNull) {
                    logInfo("Text from %s: %s", update.message.chat.id, update.message.text);

                    import std.conv;
                    auto message = SendMessageMethod();

                    message.chat_id = update.message.chat.id.to!string;
                    message.text = update.message.text;

                    // create keyboard initialized with one row with 2 buttons
                    ReplyKeyboardMarkup markup = ReplyKeyboardMarkup([
                        ["First Button", "Second Button"]
                    ]);

                    // button rows can be appended to a keyboard
                    markup ~= [KeyboardButton("Ask location", false, true)];

                    message.reply_markup = markup;

                    api.sendMessage(message);
                }
                api.updateProcessed(update);
            }

            yield();
        }
    } catch (Exception e) {
        logError(e.toString());

        throw e;
    }
}
