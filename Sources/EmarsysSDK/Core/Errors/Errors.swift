//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

enum Errors: Error, Equatable {
    case mappingFailed(String)
    case resourceNotAvailable(String)
    case dbMethodFailed(String)
    case switchToStateFailed(String)
    case secKeyCreationFailed(String)
    case urlCreationFailed(String)
    case preconditionFailed(String)
    case tokenExpired
    case dataConversionFailed(String)
    
    enum ContactRequestError: Error, Equatable {
        case contactRequestFailed(String)
    }
    
    enum NetworkingError: Error, Equatable {
        case failedRequest(HTTPURLResponse)
        case encodingFailed(String)
        case decodingFailed(String)
    }

    enum StorageError: Error, Equatable {
        case storingValueFailed(String)
        case retrievingValueFailed(String)
        case conversionFailed(String)
    }
}
