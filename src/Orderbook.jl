module Orderbook

using JSON
using JuliaDB
import Base.hash

println("\n===ORDERBOOK===\n")

# Source files
include("book.jl")
include("order-subtypes.jl")
include("handling.jl")
include("gemini.jl")
include("db.jl")
include("pricer.jl")

end # module

Orderbook.gemini_connect()

# gemini_1 = """{
#        "type":"update",
#        "eventId":1111597035,
#        "socket_sequence":8,
#        "timestamp":1501175027,
#        "timestampms":1501175027304,
#        "events":[
#           {
#              "type":"trade",
#              "tid":1111597035,
#              "price":"2559.98",
#              "amount":"0.07365713",
#              "makerSide":"ask"
#           },
#           {
#              "type":"trade",
#              "tid":1111597036,
#              "price":"2559.99",
#              "amount":"0.12365713",
#              "makerSide":"bid"
#           },
#           {
#              "type":"change",
#              "side":"ask",
#              "price":"2559.98",
#              "remaining":"20.98651537",
#              "delta":"-0.07365713",
#              "reason":"trade"},
#              {
#                 "type":"change",
#                 "side":"bid",
#                 "price":"2558.98",
#                 "remaining":"20.98651537",
#                 "delta":"-0.07365713",
#                 "reason":"trade"},
#                 {
#                    "type":"trade",
#                    "tid":1111597036,
#                    "price":"2409.99",
#                    "amount":"0.12365713",
#                    "makerSide":"bid"
#                 }]}""";
#
# book = Orderbook.Book("inventory")
# Orderbook.update!(book, Orderbook.gemini(gemini_1))
# Orderbook.price!(book)
# Orderbook.summarize_gemini(book)
# #println(Orderbook.value(book))
# book
