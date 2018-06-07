import SHA
import Requests

function do_handshake(rng::AbstractRNG, uri::Requests.URI; do_request=Requests.do_stream_request)
    # Requirement
    # @4_1_OpeningHandshake_1 Opening handshake is a valid HTTP request
    # @4_1_OpeningHandshake_4 Opening handshake Host header field
    # @4_1_OpeningHandshake_7-2 Opening handshake Sec-WebSocket-Key header field is randomly chosen
    #
    # Covered by design, as we use Requests.jl, which can be assumed to make valid HTTP requests.


    key = make_websocket_key(rng)
    expected_accept = calculate_accept(key)
    headers = make_headers(key)
    result = do_request(uri, "GET"; headers=headers)

    stream = result.socket
    if uri.scheme == "https"
        stream = TLSBufferedIO(stream)
    end

    # TODO: Any body unintentionally read during the HTTP parsing is not returned, which means that
    #       if any such bytes were read, then we will not be able to correctly read the first frame.
    HandshakeResult(expected_accept, stream, result.response.headers, b"")
end
