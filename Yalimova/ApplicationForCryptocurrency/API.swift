import Foundation
import Alamofire

struct API {
    static func Bitfinex_BTC_USD() -> DataRequest {
        return Alamofire.request(BitfinexRouter.btcusd)
    }
}

