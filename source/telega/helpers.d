module telega.helpers;

import telega.botapi : BotApi;
import telega.telegram.basic : UpdateType, Update, getUpdates;

class UpdatesRange
{
    import std.algorithm.comparison : max;

    enum bool empty = false;

    protected:
        BotApi _api;
        uint _maxUpdateId;

        UpdateType[] _allowedUpdates = [];
        ubyte _updatesLimit = 5;
        uint _timeout = 30;

    private:
        bool _isEmpty;
        Update[] _updates;
        ushort _index;

    public: @safe:
        this(BotApi api, uint maxUpdateId = 0, ubyte limit = 5, uint timeout = 30)
        {
            _api = api;
            _maxUpdateId = maxUpdateId;
            _updatesLimit = limit;
            _timeout = timeout;

            _updates.reserve(_updatesLimit);
        }

        @property
        uint maxUpdateId()
        {
            return _maxUpdateId;
        }

        auto front()
        {
            if (_updates.length == 0) {
                getUpdates();
                _maxUpdateId = max(_maxUpdateId, _updates[_index].id);
            }

            return _updates[_index];
        }

        void popFront()
        {
            _maxUpdateId = max(_maxUpdateId, _updates[_index].id);

            if (++_index >= _updates.length) {
                getUpdates();
            }
        }

    protected:
        @trusted
        void getUpdates()
        {
            do {
                _updates = _api.getUpdates(
                    _maxUpdateId+1,
                    _updatesLimit,
                    _timeout,
                    _allowedUpdates
                );
            } while (_updates.length == 0);
            _index = 0;
        }
}

@safe @nogc nothrow pure
bool isMessageType(in Update update)
{
    return !update.message.isNull;
}
