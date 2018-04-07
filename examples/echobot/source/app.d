import vibe.core.core;
import vibe.core.log;
import std.typecons;

string botToken = "123456789:BotTokenHerE";

int main(string[] args)
{
    if (args[1] != null) {
        logInfo("Setting token from first argument");
        botToken = args[1];
    }

    runTask(&listenUpdates);

    return runApplication();
}

void listenUpdates()
{
    import telega.botapi;

    try {
        auto api = new BotApi(botToken);

        while(true) {
            logInfo("Waiting for updates...");
            auto updates = api.getUpdates();
            logInfo("Got %d updates", updates.length);

            foreach (update; updates) {
                if (!update.message.isNull) {
                    logInfo("Text from %s: %s", update.message.chat.id, update.message.text);
                    api.sendMessage(update.message.chat.id, update.message.text);
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
