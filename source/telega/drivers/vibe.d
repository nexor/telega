module telega.drivers.vibe;

version(TelegaVibedDriver) enum HaveVibedDriver = true;
else enum HaveVibedDriver = false;

static if(HaveVibedDriver):

import vibe.http.client;
import vibe.stream.operations : readAllUTF8;
import vibe.core.log;
import telega.http;

class VibedHttpClient: HttpClient
{
    public:
        string sendGetRequest(string url)
        {
            HTTPClientResponse res = requestHTTP(url);

            return res.bodyReader.readAllUTF8(true);
        }

        string sendPostRequestJson(string url, string bodyJson)
        {
            string answer;

            requestHTTP(url,
                    (scope req) {
                        req.method = HTTPMethod.POST;

                        req.headers["Content-Type"] = "application/json";
                        req.writeBody( cast(const(ubyte[])) bodyJson);
                    },
                    (scope res) {
                        answer = res.bodyReader.readAllUTF8(true);
                        logDebug("Response headers:\n  %s\n  %s", res, res.headers);
                        logDiagnostic("Response body:\n  %s", answer);

                        enforce(res.statusCode == 200);
                    }
                );

            return answer;
        }
}
