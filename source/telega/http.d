module telega.http;

import std.exception;

interface HttpClient
{
    string sendGetRequest(string url);
    string sendPostRequestJson(string url, string bodyJson);
}
