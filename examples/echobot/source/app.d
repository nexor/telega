import vibe.core.core;
import vibe.core.log;
import std.typecons;

immutable string botToken = "123456789:BotTokenHerE";

int main(string[] args)
{
    runTask(&listenUpdates);

    return runApplication();
}

void listenUpdates()
{
    import telega.botapi.botapi;

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
}
