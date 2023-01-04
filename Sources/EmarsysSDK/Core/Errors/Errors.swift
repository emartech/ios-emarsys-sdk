//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

enum Errors: Error {
    case mappingFailed(String)
    case resourceNotAvailable(String)
    case dbMethodFailed(String)
    case switchToStateFailed(String)
    case secKeyCreationFailed(String)
    case urlCreationFailed(String)
    case storingValueFailed(String)
    case retrievingValueFailed(String)
    case preconditionFailed(String)
}