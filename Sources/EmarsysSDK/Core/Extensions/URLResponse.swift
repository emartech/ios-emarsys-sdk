//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

extension URLResponse {
    
    func asHttpURLResponse() throws -> HTTPURLResponse {
        guard let httpUrlResponse = self as? HTTPURLResponse else {
            throw Errors.TypeError.mappingFailed(parameter: String(describing: self), toType: String(describing: HTTPURLResponse.self))
        }
        return httpUrlResponse
    }
}
