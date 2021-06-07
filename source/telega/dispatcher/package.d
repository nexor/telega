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
                    // we need all updates with text message
                    if (!u.message.isNull)
                    {
                        foreach (filter, handler; messageHandlers){
                            if (filter.check(u.message.get)){
                                handler(u.message.get);
                                break;
                            }
                        }
                        
                    }else if(!u.edited_message.isNull)
                        foreach (filter, handler; editedMessageHandlers){
                            if (filter.check(u.edited_message.get)){
                                handler(u.edited_message.get);
                                break;
                            }
                        }

                    // mark update as processed
                    offset = max(offset, u.id) + 1;
                });
        }
    
    }        
            
}
