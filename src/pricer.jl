function price!(book::Book)
    # Evaluated whenever, I guess.
    price!(book, book.pricer)
end

function show_model(book::Book)
    # Called on book summaries.
    show_model(book.pricer)
end

function evaluate(book::Book)
    # Call on trades.
    evaluate(book.pricer)
end

mutable struct InventoryModel <: PricingModel
    buy_price  :: Float64
    sell_price :: Float64

    buy_quantity  :: Float64
    sell_quantity :: Float64

    inventory :: Float64

    reserve_price :: Float64

    prices # table

    InventoryModel() = new(0.0, 0.0, 0.05, 0.05, 0.0, 0.0)
end

function time_remaining()
   # Returns time until midnight.
   midnight = DateTime(Dates.today()) + Dates.Day(1)
   remaining = midnight - now()
   portion = remaining/Dates.Millisecond(Dates.Day(1))
   return portion
end

function get_k(book::Book)
   # Only for BTCUSD
   return 0.41557937
end

function price!(book::Book, model::InventoryModel)
    bs = parse(Float64, book.best_sell_str)
    bb = parse(Float64, book.best_buy_str)

    # println("Prices: $bs $bb")

    # Current midpoint price
    s = (bs + bb) / 2
    # println("S: $s")

    # Current inventory, 0 for the moment.
    q = inventory_num(book)
    # println("q: $q")

    # Risk aversion, parameterized.
    const λ = 0.01

    # Trade price variance.
    arr = convert(Array{Float64, 1}, select(book.trades, :price))
    σ = std(arr)
    # println("σ: $σ")

    # Terminal time is the time until midnight.
    t = time_remaining()
    # println("t: $t")

    k = get_k(book)
    # println("k: $k")

    reserve_price = s - q*λ*σ*t
    spread = λ*σ*t + 2/λ*log((1+λ/k))

    b_p = round(reserve_price - spread/2, 2)
    a_p = round(reserve_price + spread/2, 2)

    model.buy_price = b_p
    model.sell_price = a_p
    model.reserve_price = reserve_price
    model.inventory = q

    # println("Model: $model")

    return nothing
end

function show_model(model :: InventoryModel)
    println("\tPurchase price: $(model.buy_price)")
    println("\tSell price:     $(model.sell_price)")
    println("\tReserve price:  $(model.reserve_price)")
    println("\tModel spread:   $(model.sell_price - model.buy_price)")
    println("\tInventory prop: $(model.inventory)")
end

function evaluate(book::Book, trade_price :: Float64, trade_amount :: Float64)
    summarize_gemini(book)

    #println("Trade price: $trade_price Trade amount $trade_amount")
    if trade_price > book.pricer.sell_price && book.asset2 > book.pricer.sell_quantity
        println("\n")
        println(repeat("=", 30))
        println("Sale!")
        println(repeat("=", 30))
        println("\n")

        # Someone bought something from us.
        # increase our dollar holdings:
        amount = min(book.pricer.sell_quantity, trade_amount)
        book.asset1 += amount * trade_price
        # decrease our BTC holdings:
        book.asset2 -= amount

    elseif trade_price < book.pricer.buy_price && book.asset1 > book.pricer.buy_quantity
        println("\n")
        println(repeat("=", 30))
        println("Purchase!")
        println(repeat("=", 30))
        println("\n")

        # We bought something from someone else.
        # Reduce dollar holdings:
        amount = min(book.pricer.buy_quantity, trade_amount)

        book.asset1 -= amount * trade_price
        # Increase BTC holdings:
        book.asset2 += amount
    end

end

function inventory_num(book::Book)
    bs = parse(Float64, book.best_sell_str)
    bb = parse(Float64, book.best_buy_str)

    usd = book.asset1
    btc = book.asset2 * bs
    total = usd + btc

    #println("usd $usd btc $btc total $total")

    usdprop = usd / total
    btcprop = btc / total * -one(Float64)

    return usdprop + btcprop
end
