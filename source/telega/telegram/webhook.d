module telega.telegram.webhook;

import std.typecons : Nullable;
import telega.botapi : BotApi, TelegramMethod, HTTPMethod;
import telega.telegram.basic : InputFile;

struct WebhookInfo
{
    string   url;
    bool     has_custom_certificate;
    uint     pending_update_count;
    Nullable!uint     last_error_date;
    Nullable!string   last_error_message;
    Nullable!uint     max_connections;
    Nullable!string[] allowed_updates;
}

struct SetWebhookMethod
{
    mixin TelegramMethod!"/setWebhook";

    string             url;
    Nullable!InputFile certificate;
    uint               max_connections;
    string[]           allowed_updates;
}

struct DeleteWebhookMethod
{
    mixin TelegramMethod!"/deleteWebhook";
}

struct GetWebhookInfoMethod
{
    mixin TelegramMethod!("/getWebhookInfo", HTTPMethod.GET);
}

bool setWebhook(BotApi api, string url)
{
    SetWebhookMethod m = {
        url : url
    };

    return setWebhook(api, m);
}

bool setWebhook(BotApi api, ref SetWebhookMethod m)
{
    return api.callMethod!(bool, SetWebhookMethod)(m);
}

bool deleteWebhook(BotApi api)
{
    DeleteWebhookMethod m = DeleteWebhookMethod();

    return api.callMethod!(bool, DeleteWebhookMethod)(m);
}

WebhookInfo getWebhookInfo(BotApi api)
{
    GetWebhookInfoMethod m = GetWebhookInfoMethod();

    return api.callMethod!(WebhookInfo, GetWebhookInfoMethod)(m);
}

unittest
{
    class BotApiMock : BotApi
    {
        this(string token)
        {
            super(token);
        }

        T callMethod(T, M)(M method)
        {
            T result;

            logDiagnostic("[%d] Requesting %s", requestCounter, method.name);

            return result;
        }
    }

    auto api = new BotApiMock(null);

    api.setWebhook("https://webhook.url");
    api.deleteWebhook();
    api.getWebhookInfo();
}
