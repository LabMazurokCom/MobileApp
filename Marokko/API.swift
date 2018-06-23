//
//  API.swift
//  AllaGraph
//
//  Created by Алла Марокко on 18.06.18.
//  Copyright © 2018 Алла Марокко. All rights reserved.
//

import Foundation
import Alamofire

struct API {
    static func Bitfinex_BTC_USD() -> DataRequest {
        return Alamofire.request(BitfinexRouter.btcusd)
    }
    static func Bitstamp_BTC_USD() -> DataRequest {
        return Alamofire.request(BitstampRouter.btcusd)
    }
    static func CEX_BTC_USD() -> DataRequest {
        return Alamofire.request(CEXRouter.btcusd)
    }
}
