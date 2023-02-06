//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

enum Errors: SdkError {
    case resourceLoadingFailed(resource: String)
    case secKeyCreationFailed(secKey: String)
    case preconditionFailed(message: String)
    
    enum TypeError: SdkError {
        case mappingFailed(parameter: String, toType: String)
        case encodingFailed(type: String)
        case decodingFailed(type: String)
    }
    
    enum UserFacingRequestError: SdkError {
        case contactRequestFailed(url: String)
        case registerClientFailed(url: String)
    }
    
    enum NetworkingError: SdkError {
        case urlCreationFailed(url: String)
        case failedRequest(response: HTTPURLResponse)
    }

    enum StorageError: SdkError {
        case savingItemFailed(item: String, error: String)
        case storingValueFailed(key: String, osStatus: String)
        case retrievingValueFailed(key: String, osStatus: String)
    }
}

protocol SdkError: LocalizedError, Equatable {
}

extension SdkError {
    
    var errorDescription: String? {
        var result: String?
        let selfMirror = Mirror(reflecting: self)
        guard let selfName = selfMirror.children.first?.label else {
            return nil
        }
        if selfMirror.displayStyle == .enum, let associated = selfMirror.children.first  {
            let values = Mirror(reflecting: associated.value).children
            var args = [String]()
            for case let item in values where item.label != nil {
                if let value = item.value as? String {
                    args.append(value)
                }
            }
            result = selfName.localized(with: args)
        } else {
            result = selfName.localized()
        }
        return result
    }
    
}
