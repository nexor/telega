import vibe.core.core : runApplication, runTask;
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

    return runApplication();
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
            .filter!(u => !u.message.text.isNull) // we need all updates with text message
            .each!((Update u) {
                logInfo("Text from %s: %s", u.message.chat.id, u.message.text);
                api.sendMessage(u.message.chat.id, u.message.text);
                offset = max(offset, u.id)+1;
            });
    }
}
