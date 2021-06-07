module telega.dispatcher.filters;

import telega.telegram.basic:Update,Message;

interface Filter(T){
    bool check(T);
}

alias UpdateFilter = Filter!Update;
alias MessageFilter = Filter!Message;

interface EditedMessageFilter: MessageFilter{};

