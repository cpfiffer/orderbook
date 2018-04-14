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

gemini_1 = """{
       "type":"update",
       "eventId":1111597035,
       "socket_sequence":8,
       "timestamp":1501175027,
       "timestampms":1501175027304,
       "events":[
          {
             "type":"trade",
             "tid":1111597035,
             "price":"2559.98",
             "amount":"0.07365713",
             "makerSide":"ask"
          },
          {
             "type":"change",
             "side":"ask",
             "price":"2559.98",
             "remaining":"20.98651537",
             "delta":"-0.07365713",
             "reason":"trade"}]}""";
