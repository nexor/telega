import vibe.core.core : runApplication, runTask, disableDefaultSignalHandlers;
import vibe.core.log : setLogLevel, logInfo, LogLevel;
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

void listenUpdates(string token)
{
    import telega.botapi : BotApi;
    import telega.telegram.basic : Update, getUpdates, sendMessage, GetUpdatesMethod;
    import std.algorithm.iteration : filter, each;
    import std.algorithm.comparison : max;

    int offset;
    auto api = new BotApi(token);

    api.getUpdates(-1).each!((Update u) {
           offset = max(offset, u.id) + 1;
    });
    while (true)
    {
        api.getUpdates(offset)
            .each!((Update u) {
                // we need all updates with text message
                if (!u.message.isNull && !u.message.get.text.isNull)
                {
                    logInfo("Text from %s: %s", u.message.chat.id, u.message.text);
                    auto sm = u.message.reply(u.message.text.get);
                    api.sendMessage(sm);
                }

                // mark update as processed
                offset = max(offset, u.id) + 1;
            });
    }
}
