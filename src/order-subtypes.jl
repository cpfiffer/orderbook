# Order functions/structures for GDAX.
struct GDAXOrder
    kind::String
    time::String
    product_id::String
    sequence::Int64
    order_id::String
    size::String
    price::String
    side::String
    order_type::String
end

function hash(x::GDAXOrder)
    y  = hash(x.product_id)
    y += hash(x.order_id)
    y += hash(x.size)
    y += hash(x.price)
    y += hash(x.side)
    y += hash(x.order_type)
    return y
end

function broaden(x::GDAXOrder)
    size  = parse(Float64, x.size)
    price = parse(Float64, x.price)
    side  = enum_side(x.side)
    return NumOrder(price, size, side);
end

function update_best!(book::Book, new_order::GDAXOrder, order_hash::UInt64)
    simple_order = broaden(new_order)

    if simple_order.side == buy
        current_bb = best_buy(book)

        if isnullorder(current_bb)
            book.best_buy = order_hash
        elseif current_bb.price < simple_order.price
            book.best_buy = order_hash
        end

        book.orders[order_hash] = simple_order
    elseif simple_order.side == sell
        current_bs = best_sell(book)

        if isnullorder(current_bs)
            book.best_sell = order_hash
        elseif current_bs.price > simple_order.price
            book.best_sell = order_hash
        end

        book.orders[order_hash] = simple_order
    end
end

###
# Structures and handling for Gemini.
###
struct GeminiOrder
    kind::String
    eventID::Int64
    timestamp::Int64
    timestampms::Int64
    socket_sequence::Int64

    #Subheader for changes.
    eventType::String
    side::String
    price::String
    remaining::String
    delta::String
    reason::String

    #subheader for trades.
    tradeID::Int64
    amount::String
    makerSide::String

end

function broaden(x::GeminiOrder)
    size = parse(Float64, x.amount)
    price = parse(Float64, x.price)
    side = enum_side(x.side)
    return NumOrder(size, price, bid)
end

function update!(book::Book, x::Vector{GeminiOrder})

    # Add each order to the book. Gemini orders aren't particularly
    # identifiable, so we only track prices and depth.
    for i = x
        changeType = i.eventType

        if changeType == "change"

            # Update the prices we have.
            price = i.price
            side = enum_side(i.side)
            remaining = parse(Float64, i.remaining) * Int(side)

            bb = book.best_buy
            bs = book.best_sell

            if remaining == zero(Float64)
                # no need to maintain this price point.
                # println("\n===========")
                # println("remaining $remaining $(typeof(remaining))")
                # println("price     $price     $(typeof(price))")
                # println("side      $side      $(typeof(side))")

                delete!(book.prices, price)
                # println(book.prices)
            else
                # Update the price.
                book.prices[price] = remaining
            end

            if side == buy
                best_buy_prices!(book)
            elseif side == sell
                best_sell_prices!(book)
            end
        end

        if changeType == "trade"
            price = parse(Float64, i.price)
            book.last_price = price
            push!(book.trade_prices, price)
            add!(book, i)
        end
    end
end
