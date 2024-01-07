import vibe.core.core : runApplication, runTask, disableDefaultSignalHandlers;
import vibe.core.log : setLogLevel, logInfo, LogLevel;
import std.process : environment;
import std.exception : enforce;
import std.functional : toDelegate;

int main(string[] args)
{
    string botToken = environment.get("BOT_TOKEN");

    if (args.length > 1 && args[1] != null) {
        logInfo("Setting token from first argument");
        botToken = args[1];
    }

    enforce(botToken !is null, "Please provide bot token as a first argument or set BOT_TOKEN env variable");

    setLogLevel(LogLevel.diagnostic);
    listenUpdates(botToken);

    return 0;
}

void listenUpdates(string token)
{
    import telega.botapi : BotApi;
    import telega.telegram.basic : Update, getUpdates, sendMessage;
    import std.algorithm.iteration : filter, each;
    import std.algorithm.comparison : max;

    int offset;
    auto api = new BotApi(token);

    while (true)
    {
        api.getUpdates(offset)
            .each!((Update u) {
                // we need all updates with text message
                if (!u.message.isNull && !u.message.get.text.isNull)
                {
                    logInfo("Text from %s: %s", u.message.get.chat.id, u.message.get.text);
                    api.sendMessage(u.message.get.chat.id, u.message.get.text.get);
                }

                // mark update as processed
                offset = max(offset, u.id) + 1;
            });
    }
}
