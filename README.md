# Orderbook
This is a Julia package designed to track limit order books, primarily from JSON sources. As NASDAQ has not seen fit to widely distribute their valuable securities data, this only works for some cryptocurrency exchanges. At the moment it has mostly full support for Gemini's websocket feeds, and partial support for GDAX level 3 data.

I would one day like to get this up and running on FIX, but I haven't the time to parse through whatever documentation I could scrape up. If for some reason you or your firm is running their orderbook through Julia and would like to track FIX, send me an email! I would love to build up some solid FIX infrastructure.
