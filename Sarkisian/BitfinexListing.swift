import Foundation
import SwiftyJSON

struct ListingItem {
    let mid : String
    let bid : String
    let ask : String
    let last_price: String
    let low : String
    let high: String
    let volume : String
    let timestamp : String
    
    init(with json: JSON) {
        self.mid = json["mid"].stringValue
        self.bid = json["bid"].stringValue
        self.ask = json["ask"].stringValue
        self.last_price = json["last_price"].stringValue
        self.low = json["low"].stringValue
        self.high = json["high"].stringValue
        self.volume = json["volume"].stringValue
        self.timestamp = json["timestamp"].stringValue
    }
}


