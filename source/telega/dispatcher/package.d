module telega.dispatcher;

import telega:BotApi;
import telega.telegram.basic:Update,Message;
public import telega.dispatcher.filters;
class Dispatcher{
    BotApi bot;
    this(BotApi bot){
        this.bot = bot;
    }
    void delegate(Message)[MessageFilter] messageHandlers;
    void delegate(Message)[EditedMessageFilter] editedMessageHandlers;
    void runPolling(){
        import telega.telegram.basic : Update, getUpdates, sendMessage;
        import std.algorithm.iteration : filter, each;
        import std.algorithm.comparison : max;
        int offset;
        while (true)
        {
            bot.getUpdates(offset)
                .each!((Update u) {
                    offset = max(offset, u.id) + 1;
                    static foreach(updateField,handlerContainer; [
                        "message":"messageHandlers",
                        "edited_message":"editedMessageHandlers"])
                        mixin(`
                        if (!u.`~updateField~`.isNull){
                            foreach (filter, handler; `~ handlerContainer~ `){
                                if (filter.check(u.`~updateField~`.get)){
                                    handler(u.`~updateField~`.get);
                                    break;
                                }
                            }
                            //return;
                        }`);
                });
        }
    
    }        
            
}
