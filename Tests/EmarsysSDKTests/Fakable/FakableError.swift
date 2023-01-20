//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

enum FakableError: Error {
    case noPropertyFound(String)
    case assertionFailed(String)
    case typeMismatch(String)
}
