module telega.dispatcher.filters;

import telega.telegram.basic:Update,Message;

interface Filter(T){
    bool check(T);
}

//alias UpdateFilter = Filter!Update;
alias MessageFilter = Filter!Message;
interface EditedMessageFilter: MessageFilter{};

class TextFilter: MessageFilter, EditedMessageFilter{
    string text;
    this(string text){
        this.text = text;
    }
    bool check(Message m){
        if (!m.text.isNull){
            if (m.text.get == text){
                return true;
            }
        }
        return false;
    }

}






