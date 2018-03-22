@enum Side buy sell
@enum Exchange gdax

function enum_side(side::String)
    if side == "buy"
        return Side.buy
    elseif side == "sell"
        return Side.sell
    end
    return -1
end

struct Order
   price::Float64
   size::Float64
   side::Side
end

mutable struct Book
   orders::Dict{UInt64, Order}
end

function update!(book::Book, order::String, exchange::Exchange)
   if exchange == Exchange.gdax

   end
end
