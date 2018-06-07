
using  DandelionWebSockets
import DandelionWebSockets: state_open, state_closing, state_closed,
                            state_connecting, on_text, on_binary
using URIParser

const trades_directory = "/home/cameron/cryptodata/trades"

mutable struct MyHandler <: WebSocketHandler
    client::WSClient
    stop_channel::Channel{Any}
    book::Book
    counter::Int64
    errors::Int64
    received::Int64
    close::Bool

    MyHandler(cli, stop, ob) = new(cli, stop, ob, 0, 0, 0, false)
end

function on_text(handler::MyHandler, text::String)
    #println("\n====new message====")

    handler.received += 1
    handler.counter = handler.counter + 1

    if handler.book.mode == nominal
        try
            update!(handler.book, gemini(text))
            price!(handler.book)

            if handler.book.mode == nominal
                #Trade
            end

            if handler.counter == 100
                summarize_gemini(handler.book)
                handler.counter = 0
            end
        catch y
            println("Error: $y")
            println(catch_stacktrace())
            handler.errors += 1
            handler.close = true
            handler.book.mode = notrade
        end

        err = handler.errors
        rec = handler.received
    elseif handler.book.mode == notrade
        # Pull all current trades and don't make new ones.
    else
        # Emergency!
    end
end

on_binary(::MyHandler, data::Vector{UInt8}) = println("Received: $(String(data))")

function state_closing(handler::MyHandler)
    println("State: CLOSING")
    handler.close = true
    save(handler.book.trades, trades_directory)
end

state_connecting(::MyHandler) = println("State: CONNECTING")

function state_open(handler::MyHandler)
    println("State: OPEN")

    # Send events subscription.
    #events_uri = URI("wss://api.gemini.com/v1/order/events")

    # send_text()
end

function state_closed(handler::MyHandler)
    println("State: CLOSED")

    # Signal the script that the connection is closed.
    put!(handler.stop_channel, true)
end

function run(handler::MyHandler)
    try
        while true
            if handler.close
                throw("Handler told us to close.")
            end
            sleep(2)
            #println("Running...")
        end
    catch
        handler.close = true
        handler.book.mode = notrade
        put!(handler.stop_channel, true)
        println("Stopping...")
    end

    #println("\nSaving trades to '$trades_directory'...")
    #save(handler.book.trades, trades_directory)
end

function gemini_connect(model = "inventory")
    gemini_sandbox_uri = URI("wss://api.sandbox.gemini.com/v1/marketdata/BTCUSD")
    events_uri = URI("wss://api.sandbox.gemini.com/v1/order/events")
    #gemini_uri = URI("wss://api.gemini.com/v1/marketdata/BTCUSD")
    #echo_uri = URIParser.URI("ws://echo.websocket.org")

    client = WSClient(Nullable{WebSocketsConnection}(), do_handshake_gem)
    stop_chan = Channel{Any}(3)
    book = Book(model)
    handler = MyHandler(client, stop_chan, book)

    wsconnect(client, events_uri, handler)

    cryptobot = @schedule run(handler)

    line = readline(STDIN)

    try
        schedule(cryptobot, InterruptException(), error = true)
    catch
        println("Task already stopped.")
    end

    handler.close = true

    take!(stop_chan)
    stop(client)
    take!(stop_chan)
end
