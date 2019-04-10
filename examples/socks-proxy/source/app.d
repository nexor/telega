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

    setLogLevel(LogLevel.debugV);

    runTask(&listenUpdates);

    return runApplication();
}

void listenUpdates()
{
    import telega.botapi;
    import telega.drivers.requests : RequestsHttpClient;
    import std.algorithm.iteration : filter, map;

    try {
        auto httpClient = new RequestsHttpClient();

        /+ here you can use your SOCKS5 proxy server accepting unauthorized requests +/
        // SOCKS 5 proxy host and port, no authentication
        httpClient.setProxy("127.0.0.1", 1080);

        auto api = new BotApi(botToken, BaseApiUrl, httpClient);
        auto updatesRange = new UpdatesRange(api, 0);
        auto messageUpdatesRange = updatesRange
                                       .filter!isMessageType
                                       .map!(u => u.message);

        foreach (ref Message m; messageUpdatesRange) {
            logInfo("Text from %s: %s", m.chat.id, m.text);
            api.sendMessage(m.chat.id, m.text);

            logInfo("maxUpdateId is %d", updatesRange.maxUpdateId);
        }

    } catch (Exception e) {
        logError(e.toString());

        throw e;
    }
}
