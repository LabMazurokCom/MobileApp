//
//  CEXRouter.swift
//  AllaGraph
//
//  Created by Алла Марокко on 23.06.18.
//  Copyright © 2018 Алла Марокко. All rights reserved.
//

import Foundation
import Alamofire

enum CEXRouter: URLRequestConvertible {
    static var baseURL: String = "https://cex.io/api/ticker/"
    
    case btcusd
    case ethusd
    
    
    
    var method: Alamofire.HTTPMethod {
        return .get
    }
    
    var path: String {
        switch self {
        case .btcusd:
            return "BTC/USD/"
        case .ethusd:
            return "ETH/USD/"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = Foundation.URL(string: CEXRouter.baseURL)!
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        
        let urlEncoder = URLEncoding.default
        
        switch self {
        case .btcusd,
             .ethusd:
            return try urlEncoder.encode(urlRequest, with: nil)
        }
    }
}


