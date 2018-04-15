function trade_table()
    # Return a trade table.
    # timestamp, price, size, makerSide
    x = table([], [], [], [],
            names = [:timestampms, :price, :size, :makerside])

    return x
end

function add!(book::Book, x::GeminiOrder)
    newrow = (x.timestampms, parse(Float64, x.price),
    parse(Float64, x.amount), x.makerSide)
    push!(rows(book.trades), newrow)
    return nothing
end
