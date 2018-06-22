import Foundation
import Alamofire

enum BitfinexRouter: URLRequestConvertible {
    static var baseURL: String = "https://api.bitfinex.com/v1/book/"
    
    case btcusd
    
    var method: Alamofire.HTTPMethod {
        return .get
    }
    
    var path: String {
        switch self {
        case .btcusd:
            return "btcusd/"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = Foundation.URL(string: BitfinexRouter.baseURL)!
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        let urlEncoder = URLEncoding.default
        
        switch self {
        case .btcusd:
            return try urlEncoder.encode(urlRequest, with: ["limit_bids": 10, "limit_asks": 10, "group": 1])
        }
    }
}

