//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

enum HttpMethod: String, Codable {
    case GET
    case POST
    case PUT
    case DELETE
}

extension URLRequest {

    private static let encoder = JSONEncoder()

    static func create(url: URL, method: HttpMethod = .GET, headers: [String: String]? = nil, body: (any Codable)? = nil) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        if let body {
            request.httpBody = try encoder.encode(body)
        }
        return request
    }
    
}
