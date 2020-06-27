module telega.telegram.inline;

import std.typecons : Nullable;
import std.meta : AliasSeq;
import telega.botapi : BotApi, TelegramMethod, HTTPMethod;
import telega.telegram.basic : ParseMode, InlineKeyboardMarkup, InputMessageContent, User, Location;
import telega.serialization : JsonableAlgebraicProxy;

struct InlineQuery
{
    string id;
    User from;
    Nullable!Location location;
    string query;
    string offset;
}

alias InlineQueryResultStructs = AliasSeq!(
    InlineQueryResultArticle, InlineQueryResultPhoto, InlineQueryResultGif, InlineQueryResultMpeg4Gif,
    InlineQueryResultVideo, InlineQueryResultAudio, InlineQueryResultVoice, InlineQueryResultDocument,
    InlineQueryResultLocation, InlineQueryResultVenue, InlineQueryResultContact, InlineQueryResultGame,
    InlineQueryResultCachedPhoto, InlineQueryResultCachedGif, InlineQueryResultCachedMpeg4Gif,
    InlineQueryResultCachedSticker, InlineQueryResultCachedDocument, InlineQueryResultCachedVideo,
    InlineQueryResultCachedVoice, InlineQueryResultCachedAudio
);

alias InlineQueryResult = JsonableAlgebraicProxy!InlineQueryResultStructs;

mixin template InlineQueryFields()
{
    Nullable!InlineKeyboardMarkup reply_markup;
    Nullable!InputMessageContent  input_message_content;
}

struct InlineQueryResultArticle
{
    string type = "article";
    string id;
    string title;
    Nullable!string url;
    Nullable!bool hide_url;
    Nullable!string description;
    Nullable!string thumb_url;
    Nullable!uint thumb_width;
    Nullable!uint thumb_height;

    Nullable!InlineKeyboardMarkup reply_markup;
    InputMessageContent  input_message_content; // can't be nullable
}

struct InlineQueryResultPhoto
{
    string type = "photo";
    string id;
    string photo_url;
    string thumb_url;
    Nullable!uint photo_width;
    Nullable!uint photo_height;
    Nullable!string title;
    Nullable!string description;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultGif
{
    string type = "gif";
    string id;
    string gif_url;
    Nullable!uint gif_width;
    Nullable!uint gif_height;
    Nullable!uint gif_duration;
    Nullable!string thumb_url;
    Nullable!string title;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultMpeg4Gif
{
    string type ="mpeg4_gif";
    string id;
    string mpeg4_url;
    Nullable!uint mpeg4_width;
    Nullable!uint mpeg4_height;
    Nullable!uint mpeg4_duration;
    Nullable!string thumb_url;
    Nullable!string title;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultVideo
{
    string type ="video";
    string id;
    string video_url;
    string mime_type;
    string thumb_url;
    string title;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;
    Nullable!uint video_width;
    Nullable!uint video_height;
    Nullable!uint video_duration;
    Nullable!string description;

    mixin InlineQueryFields;
}

struct InlineQueryResultAudio
{
    string    type = "audio";
    string    id;
    string    audio_url;
    string    title;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;
    Nullable!string    performer;
    Nullable!uint      audio_duration;

    mixin InlineQueryFields;
}

struct InlineQueryResultVoice
{
    string    type = "voice";
    string    id;
    string    voice_url;
    string    title;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;
    Nullable!uint      voice_duration;

    mixin InlineQueryFields;
}

struct InlineQueryResultDocument
{
    string    type = "document";
    string    id;
    string    title;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;
    Nullable!string    document_url;
    Nullable!string    mime_type;
    Nullable!string    description;
    Nullable!string    thumb_url;
    Nullable!uint      thumb_width;
    Nullable!uint      thumb_height;

    mixin InlineQueryFields;
}

struct InlineQueryResultLocation
{
    string type = "location";
    string id;
    float latitude;
    float longitude;
    string title;
    Nullable!uint live_period;
    Nullable!string thumb_url;
    Nullable!uint thumb_width;
    Nullable!uint thumb_height;

    mixin InlineQueryFields;
}

struct InlineQueryResultVenue
{
    string type = "venue";
    string id;
    float latitude;
    float longitude;
    string title;
    string address;
    Nullable!string foursquare_id;
    Nullable!string foursquare_type;
    Nullable!string thumb_url;
    Nullable!uint thumb_width;
    Nullable!uint thumb_height;

    mixin InlineQueryFields;
}

struct InlineQueryResultContact
{
    string type = "contact";
    string id;
    string phone_number;
    string first_name;
    Nullable!string last_name;
    Nullable!string thumb_url;
    Nullable!uint thumb_width;
    Nullable!uint thumb_height;

    mixin InlineQueryFields;
}

struct InlineQueryResultGame
{
    string type = "game";
    string id;
    string game_short_name;
    Nullable!InlineKeyboardMarkup reply_markup;
}


struct InlineQueryResultCachedPhoto
{
    string type = "photo";
    string id;
    string photo_file_id;
    Nullable!string title;
    Nullable!string description;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedGif
{
    string type = "gif";
    string id;
    string gif_file_id;
    Nullable!string title;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedMpeg4Gif
{
    string type = "mpeg4_gif";
    string id;
    string mpeg4_file_id;
    Nullable!string title;
    Nullable!string caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedSticker
{
    string type = "sticker";
    string id;
    string sticker_file_id;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedDocument
{
    string type = "document";
    string    id;
    string    title;
    string    document_file_id;
    Nullable!string    description;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedVideo
{
    string type = "video";
    string    id;
    string    video_file_id;
    string    title;
    Nullable!string    description;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

struct InlineQueryResultCachedVoice
{
    string type = "voice";
    string    id;
    string    voice_file_id;
    string    title;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}


struct InlineQueryResultCachedAudio
{
    string type = "audio";
    string    id;
    string    audio_file_id;
    Nullable!string    caption;
    Nullable!ParseMode parse_mode;

    mixin InlineQueryFields;
}

// methods

struct AnswerInlineQueryMethod
{
    mixin TelegramMethod!"/answerInlineQuery";

    string              inline_query_id;
    InlineQueryResult[] results;
    uint                cache_time;
    bool                is_personal;
    string              next_offset;
    string              switch_pm_text;
    string              switch_pm_parameter;
}

bool answerInlineQuery(BotApi api, ref AnswerInlineQueryMethod m)
{
    return api.callMethod!bool(m);
}

bool answerInlineQuery(BotApi api, string inlineQueryId, InlineQueryResult[] results)
{
    AnswerInlineQueryMethod m = {
        inline_query_id : inlineQueryId,
        results : results
    };

    return api.answerInlineQuery(m);
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

    InlineQueryResult[] iqr = new InlineQueryResult[20];

    iqr[0] = InlineQueryResultArticle();
    iqr[1] = InlineQueryResultPhoto();
    iqr[2] = InlineQueryResultGif();
    iqr[3] = InlineQueryResultMpeg4Gif();
    iqr[4] = InlineQueryResultVideo();
    iqr[5] = InlineQueryResultAudio();
    iqr[6] = InlineQueryResultVoice();
    iqr[7] = InlineQueryResultDocument();
    iqr[8] = InlineQueryResultLocation();
    iqr[9] = InlineQueryResultVenue();
    iqr[10] = InlineQueryResultContact();
    iqr[11] = InlineQueryResultGame();
    iqr[12] = InlineQueryResultCachedPhoto();
    iqr[13] = InlineQueryResultCachedGif();
    iqr[14] = InlineQueryResultCachedMpeg4Gif();
    iqr[15] = InlineQueryResultCachedSticker();
    iqr[16] = InlineQueryResultCachedDocument();
    iqr[17] = InlineQueryResultCachedVideo();
    iqr[18] = InlineQueryResultCachedVoice();
    iqr[19] = InlineQueryResultCachedAudio();

    api.answerInlineQuery("answer-inline-query", iqr);
}
