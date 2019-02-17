module telega.drivers.requests;

version(TelegaRequestsDriver) enum HaveRequestsDriver = true;
else enum HaveRequestsDriver = false;

static if(HaveRequestsDriver):

import telega.http;
import requests;
import socks.socks5;

class RequestsHttpClient: HttpClient
{
    import core.time;

    protected:
        string proxyHost;
        ushort proxyPort;

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

        void setProxy(string host, ushort port)
        {
            proxyHost = host;
            proxyPort = port;
        }

    private:
        NetworkStream createNetworkStream(string scheme, string host, ushort port)
        {
            NetworkStream stream = new TCPStream();
            stream.readTimeout = 0.seconds;

            if (proxyHost !is null) {
                proxyConnect(stream, host, port);
            } else {
                stream.connect(host, port);
            }

            final switch (scheme) {
                case "http":
                    // do nothing
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

        void proxyConnect(NetworkStream stream, string host, ushort port)
        {
            const Socks5Options options = {
                host: proxyHost,
                port: proxyPort,
                resolveHost: true
            };

            SocksTCPConnector connector = (in string host, in ushort port)
            {
                stream.connect(host, port);

                return true;
            };
            SocksDataReader reader = (ubyte[] data)
            {
                stream.receive(data);
            };
            SocksDataWriter writer = (in ubyte[] data)
            {
                stream.send(data);
            };

            Socks5 proxy = Socks5(reader, writer, connector);
            proxy.connect(options, host, port);
        }
}
