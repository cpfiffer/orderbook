struct gdax_order
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

function hash(x::gdax_order)
   y  = hash(x.product_id)
   y += hash(x.order_id)
   y += hash(x.size)
   y += hash(x.price)
   y += hash(x.side)
   y += hash(x.order_type)
   return y
end
