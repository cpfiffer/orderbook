using Nettle
using JSON

### GEMINI ###
# Grab keys, stored elsewhere.
include("/home/cameron/cryptodata/keys.jl")

function do_handshake_gem(rng::AbstractRNG, uri::Requests.URI; do_request=Requests.do_stream_request)
    key = make_websocket_key(rng)
    expected_accept = calculate_accept(key)
    headers = make_headers_gem()
    result = do_request(uri, "GET"; headers=headers)

    stream = result.socket
    if uri.scheme == "https"
        stream = TLSBufferedIO(stream)
    end

    HandshakeResult(expected_accept, stream, result.response.headers, b"")
end

function make_headers_gem(key::String, payload::Dict)
    (paystr, signature) = make_payload(payload)
    headers = Dict(
        "Upgrade" => "websocket",
        "Connection" => "Upgrade",
        "Sec-WebSocket-Key" => key,
        "Sec-WebSocket-Version" => "13",
        "X-GEMINI-APIKEY" => api_key,
        "X-GEMINI-PAYLOAD" => paystr,
        "X-GEMINI-SIGNATURE" => signature)
    return headers
end

function make_payload_gem(val::Dict)
    str       = json(val)
    b64       = base64encode(str)
    signature = hexdigest("sha384", api_secret, b64)
    return (b64, signature)
end



# make_headers_gem(api_key, make_payload(payload))
