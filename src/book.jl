@enum Side buy=1 sell=-1 null=0
@enum Exchange GDAX Gemini
@enum StopType nominal notrade emergency

abstract type PricingModel end

struct NullModel <: PricingModel end

function enum_side(side::String)
    if side == "buy" || side == "bid"
        return buy
    elseif side == "sell"|| side == "ask"
        return sell
    end
    return null
end

struct NumOrder
    size ::Float64
    price::Float64
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

    prices :: Dict{String, Float64}

    best_buy_str  :: String
    best_sell_str :: String

    last_price   :: Float64
    trade_prices :: Vector{Float64}
    trades # Table

    pricer :: PricingModel

    asset1 :: Float64
    asset2 :: Float64

    start_time :: DateTime

    mode :: StopType

    socket_sequence :: Int64

    Book() = new(Dict(), 0.0, 0.0, Vector{UInt64}([]), Vector{UInt64}([]),
        Dict{String, Float64}(), "0", "0", zero(Float64), Vector{Float64}([]),
        trade_table(), NullModel(), 1000.0, 0.0, now(), nominal, -1)

    function Book(model::String)
        if model == "inventory"
            return new(Dict(), 0.0, 0.0, Vector{UInt64}([]), Vector{UInt64}([]),
                Dict{String, Float64}(), "0", "0", zero(Float64), Vector{Float64}([]),
                trade_table(), InventoryModel(), 1000.0, 0.0, now(), nominal, -1)
        else
            return Book()
        end
    end
end

function value(book::Book)
    bs = parse(Float64, book.best_sell_str)

    val = book.asset1 + book.asset2 * bs

    return round(val, 2)
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

function best_sell_prices!(book::Book)
    init :: Bool = true
    lowest = 0
    lowest_str = "0"
    for i = keys(book.prices)
        if sign(book.prices[i]) < 0

            numval :: Float64 = parse(Float64, i) * -one(Float64)

            if init
                init = false
                lowest = numval
                lowest_str = i
            elseif numval > lowest
                lowest = numval
                lowest_str = i
            end
        end
    end

    book.best_sell_str = lowest_str
end

function best_buy_prices!(book::Book)
    highest = 0
    highest_str = "0"
    for i = keys(book.prices)
        if sign(book.prices[i]) > 0
            numval :: Float64 = parse(Float64, i)
            if numval > highest || highest == 0
                highest = numval
                highest_str = i
            end
        end
    end

    book.best_buy_str = highest_str
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

function summarize_gemini(book::Book)
    println("\n===Summary===")

    now_minutes = floor(now(), Dates.Minute)
    start_minutes = floor(book.start_time, Dates.Minute)
    running_time = Dates.Minute(now_minutes - start_minutes)
    println("Running time:       $running_time")

    println("Mode:               $(book.mode)")

    numorders = length(book.prices)

    println("Number of orders:   $numorders")

    bb = book.best_buy_str

    if bb == "0"
        #
    else
        bbq = book.prices[bb]

        println("Best bid price:     $bb")
        println("Best bid quant:     $bbq")
    end

    bs = book.best_sell_str

    if bs == "0"
        #
    else
        bsq = book.prices[bs]

        println("Best ask price:     $bs")
        println("Best ask quant:     $bsq")
    end

    midpoint = (parse(Float64, bs) + parse(Float64, bb)) / 2
    println("Midpoint:           $midpoint")

    spread = parse(Float64, bs) - parse(Float64, bb)
    println("Spread:             $spread")

    lastprice = book.last_price
    println("Last price:         $lastprice")

    vol = var(book.trade_prices)
    println("Volatility:         $vol")

    sd = sqrt(vol)
    println("Standard deviation: $sd")

    num_trades = length(book.trade_prices)
    println("Number of trades:   $num_trades")

    println("Dollars:            $(book.asset1)")
    println("BTC:                $(book.asset2)")
    println("Value:              \$$(value(book))")

    println("Model info:")
    show_model(book)
end

function delete_order!(book::Book, key::String)
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
