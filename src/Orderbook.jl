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

end # module

#Orderbook.gemini_connect()

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
#              "type":"change",
#              "side":"ask",
#              "price":"2559.98",
#              "remaining":"20.98651537",
#              "delta":"-0.07365713",
#              "reason":"trade"}]}""";
#
# book = Orderbook.Book()
# Orderbook.update!(book, Orderbook.gemini(gemini_1))
#
