# Functions for parsing out IDs for different exchanges.
last_sequence = 0

function good_order(side::String, size::String, price::String, id::String)
    # Evaluates whether an order is good to use.
    if length(side) > 0 &&
        length(size) > 0 &&
        length(price) > 0 &&
        length(id) > 0

        return true
    else
        return false
    end
end

function qget(dict::Dict, str::String)::String
    return get(dict, str, "")
end

function nget(dict::Dict, str::String)::Int64
    return get(dict, str, -1)
end

function dictget(dict::Dict, str::String)::Dict
    return get(dict, str, dict())
end

function gdax_l3(update_string::String)
    # {
    #     "type": "received",
    #     "time": "2014-11-07T08:19:27.028459Z",
    #     "product_id": "BTC-USD",
    #     "sequence": 10,
    #     "order_id": "d50ec984-77a8-460a-b958-66f114b0de9b",
    #     "size": "1.34",
    #     "price": "502.1",
    #     "side": "buy",
    #     "order_type": "limit"
    # }
    odict = JSON.parse(update_string)

    kind = get(odict, "type", "")
    time = get(odict, "time", "")
    prod = get(odict, "product_id", "")
    sequence = get(odict, "sequence", "")

    # Verify that sequence number is monotonically increasing
    if (last_sequence + 1) == sequence

        # New order
        if kind == "received"
            side = get(odict, "side", "")
            size = get(odict, "size", "")
            price = get(odict, "price", "")
            order_id = get(odict, "order_id", "")
            order_type = get(odict, "order_type", "")

            if good_order(side, size, price, order_id)
                new_order::GDAXOrder = GDAXOrder(kind, time, prod,
                                                   sequence, order_id,
                                                   size, price, side,
                                                   order_type)
                return new_order
            else
                # Panic!
                # :TODO Why is there a bad order?
            end
        end
    else
        # Panic!
        # :TODO Terminate connection and redo.
    end


    return odict
end

function gemini(update_string::String)
    odict = JSON.parse(update_string)

    result = get(odict, "result", "")

    if length(result) > 0
        println("Received error message:")
        println(update_string)
    else
        orders = Vector{GeminiOrder}([])

        kind = qget(odict, "type")::String
        eventID = nget(odict, "eventId")
        socket_sequence = nget(odict, "socket_sequence")
        timestamp = nget(odict, "timestamp")
        timestampms = nget(odict, "timestampms")
        events = get(odict, "events", Array{Any, 1}())

        for i = events
            # println(i)

            eventType = qget(i, "type")::String

            if eventType == "change"
                # Change stuff.
                side = qget(i, "side")::String
                price = qget(i, "price")::String
                remaining = qget(i, "remaining")::String
                delta = qget(i, "delta")::String
                reason = qget(i, "reason")::String

                #Generate a new order.
                new_order = GeminiOrder(kind,
                    eventID,
                    timestamp,
                    timestampms,
                    socket_sequence,
                    eventType,
                    side,
                    price,
                    remaining,
                    delta,
                    reason, -1, "", "")

                push!(orders, new_order)

            elseif eventType == "trade"
                # Trade stuff.
                side = qget(i, "side")
                tradeID = nget(i, "tid")
                price = qget(i, "price")
                amount = qget(i, "amount")
                makerSide = qget(i, "makerSide")

                #Generate a new order.
                new_order = GeminiOrder(kind,
                    eventID,
                    timestamp,
                    timestampms,
                    socket_sequence,
                    eventType,
                    side,
                    price,
                    "",
                    "",
                    "",
                    tradeID,
                    amount,
                    makerSide)

                push!(orders, new_order)
            else
                println("Unexpected message type.")
                println(update_string)
            end
        end
    end

    return orders
end
