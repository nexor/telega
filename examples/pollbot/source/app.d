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
    import telega.telegram.basic : Update, getUpdates;
    import std.algorithm.iteration : each;
    import std.algorithm.comparison : max;
    import pollbot.pollbot : PollBot;

    int offset;
    auto api = new BotApi(token);
    auto bot = new PollBot(api);

    while (true)
    {
        api.getUpdates(offset)
            .each!((Update u) {
                bot.onUpdate(u);

                // mark update as processed
                offset = max(offset, u.id) + 1;
            });
    }
}
