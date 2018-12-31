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

    setLogLevel(LogLevel.diagnostic);

    runTask(&listenUpdates);

    return runApplication();
}

void listenUpdates()
{
    import telega.botapi;
    import telega.drivers.requests : RequestsHttpClient;

    try {
        auto httpClient = new RequestsHttpClient();

        /+ here you can use your SOCKS5 proxy server accepting unauthorized requests +/
        // SOCKS 5 proxy host and port, no authentication
        httpClient.setProxy("10.0.3.1", 1080);

        auto api = new BotApi(botToken, BaseApiUrl, httpClient);

        while(true) {
            logInfo("Waiting for updates...");
            auto updates = api.getUpdates();
            logInfo("Got %d updates", updates.length);

            foreach (update; updates) {
                if (!update.message.isNull && !update.message.text.isNull) {
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
