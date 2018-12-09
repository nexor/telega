module telega.drivers.requests;

version(TelegaRequestsDriver) enum HaveRequestsDriver = true;
else enum HaveRequestsDriver = false;

static if(HaveRequestsDriver):

import telega.http;
import requests;
import vibe.core.log;

class RequestsHttpClient: HttpClient
{
    import core.time;

    private:
        Request rq;

    public:
        this()
        {
            rq.socketFactory = &createNetworkStream;
            rq.timeout = 0.seconds;
        }

        string sendGetRequest(string url)
        {
            Response rs = rq.get(url);

            return rs.responseBody.toString();
        }

        string sendPostRequestJson(string url, string bodyJson)
        {
            rq.addHeaders(["Content-Type": "application/json"]);
            Response rs = rq.post(url, bodyJson);

            return rs.responseBody.toString();
        }

    private:
        NetworkStream createNetworkStream(string scheme, string host, ushort port)
        {
            NetworkStream stream = new TCPStream();
            stream.readTimeout = 0.seconds;

            final switch (scheme) {
                case "http":
                    stream.connect(host, port);
                    break;

                case "https":
                    auto sslOptions = SSLOptions();
                    sslOptions.setVerifyPeer(false); // TODO enable ssl check
                    stream = new SSLStream(stream, sslOptions);
                    stream.readTimeout = 0.seconds;
                    break;
            }

            return stream;
        }
}
