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
            println("Order type: $kind")
            side = get(odict, "side", "")
            size = get(odict, "size", "")
            price = get(odict, "price", "")
            order_id = get(odict, "order_id", "")
            order_type = get(odict, "order_type", "")

            if good_order(side, size, price, order_id)
                new_order::gdax_order = gdax_order(kind, time, prod,
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
