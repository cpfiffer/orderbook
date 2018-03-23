module Orderbook

using JSON
import Base.hash

println("\n===ORDERBOOK===\n")

# Source files
include("book.jl")
include("order-subtypes.jl")
include("handling.jl")

gdax_example = """{
    "type": "received",
    "time": "2014-11-07T08:19:27.028459Z",
    "product_id": "BTC-USD",
    "sequence": 1,
    "order_id": "d50ec984-77a8-460a-b958-66f114b0de9b",
    "size": "1.34",
    "price": "502.1",
    "side": "buy",
    "order_type": "limit"}""";

gdax_example2 = """{
    "type": "received",
    "time": "2014-11-07T08:19:27.028459Z",
    "product_id": "BTC-USD",
    "sequence": 1,
    "order_id": "d50ec984-77a8-460a-b958-66f114b0de9b",
    "size": "1.36",
    "price": "502.15",
    "side": "sell",
    "order_type": "limit"}""";

book = Book()
update!(book, gdax_example, GDAX)
update!(book, gdax_example2, GDAX)

summarize(book)

end # module
