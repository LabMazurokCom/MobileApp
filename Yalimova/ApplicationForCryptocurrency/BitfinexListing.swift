import Foundation
import SwiftyJSON

struct Listing {
    let timestamp : String
    let asks: [ListingItem]
    let bids: [ListingItem]
    
    init(with json: JSON) {
        self.timestamp = json["timestamp"].stringValue
        self.asks = json["asks"].arrayValue.map({ ListingItem.init(with: $0) })
        self.bids = json["bids"].arrayValue.map({ ListingItem.init(with: $0) })
    }
}

struct ListingItem {
    let price : Double
    let amount : Double
   
    init(with json: JSON) {
            self.price = json["price"].doubleValue
            self.amount = json["amount"].doubleValue
    }
}
