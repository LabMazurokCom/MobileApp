//
//  BitstampRouter.swift
//  AllaGraph
//
//  Created by Алла Марокко on 23.06.18.
//  Copyright © 2018 Алла Марокко. All rights reserved.
//

import Foundation
import Alamofire

enum BitstampRouter: URLRequestConvertible {
    static var baseURL: String = "https://www.bitstamp.net/api/v2/ticker/"
    
    case btcusd
    case ethusd
    
    
    
    var method: Alamofire.HTTPMethod {
        return .get
    }
    
    var path: String {
        switch self {
        case .btcusd:
            return "btcusd/"
        case .ethusd:
            return "ethusd/"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = Foundation.URL(string: BitstampRouter.baseURL)!
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


