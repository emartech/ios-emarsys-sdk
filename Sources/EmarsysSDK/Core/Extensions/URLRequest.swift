//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

enum HttpMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

extension URLRequest {
    
    static func create(url: URL, method: HttpMethod = .GET, headers: [String: String]? = nil, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
    
}
