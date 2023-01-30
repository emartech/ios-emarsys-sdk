//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

enum FakedError: Error {
    case noPropertyFound(String)
    case assertionFailed(String)
    case typeMismatch(String)
    case missingFunction(String)
    case invalidParameter(String)
    
}
