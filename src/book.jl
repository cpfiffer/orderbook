@enum Side buy=1 sell=-1 null=0
@enum Exchange GDAX

function enum_side(side::String)
    if side == "buy"
        return buy
    elseif side == "sell"
        return sell
    end
    return null
end

struct NumOrder
   price::Float64
   size ::Float64
   side ::Side
end

nullorder() = NumOrder(0.0, 0.0, null)

function isnullorder(o::NumOrder)
    if o.side == null
        return true
    end
    return false
end

mutable struct Book
   orders :: Dict{UInt64, NumOrder}

   best_buy  :: UInt64
   best_sell :: UInt64

   buys  :: Vector{UInt64}
   sells :: Vector{UInt64}

   Book() = new(Dict(), 0.0, 0.0)
end

function getorder(book::Book, key::UInt64)
    if haskey(book.orders, key)
        return book.orders[key]
    end
    return nullorder()
end

function best_sell(book::Book)
    getorder(book, book.best_sell)
end

function best_buy(book::Book)
    getorder(book, book.best_buy)
end


function update!(book::Book, message::String, exchange::Exchange)
   if exchange == GDAX
       new_order::GDAXOrder = gdax_l3(message)
       order_hash::UInt64 = hash(new_order)
       if haskey(book.orders, order_hash)
           # Deal with this. :TODO.
       else
           update_best!(book, new_order, order_hash)
           book.orders[order_hash] = broaden(new_order)
       end
   end
end

function summarize(book::Book)
    bb_hash = book.best_buy
    bs_hash = book.best_sell

    best_sell_price = best_sell(book).price
    best_buy_price  = best_buy(book).price

    order_count = length(book.orders)

    println("BB_hash: $bb_hash\nBS_hash: $bs_hash\
    \nBest sell price: $best_sell_price\
    \nBest buy price: $best_buy_price\
    \nOrder count: $order_count\n")
end

function delete!(book::Book, key::String)
    if haskey(book.orders, key)
        if key == book.best_buy || key == book.best_sell
            # TODO: Pull top order from by/sell
        end
    end
    delete!(book.orders, key)
end

function next_buy(book::Book)::UInt64
    buys::Vector{UInt64} = book.buys
    highest_index::UInt64 = zero(UInt64)
    highest::NumOrder = nullorder()

    for i = 1:length(buys)
        order::NumOrder = getorder(buys[i])
        price::Float64  = order.price
        if price > highest.price
            highest = order
        end
    end

    return highest
end
