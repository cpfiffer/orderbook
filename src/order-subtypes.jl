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
