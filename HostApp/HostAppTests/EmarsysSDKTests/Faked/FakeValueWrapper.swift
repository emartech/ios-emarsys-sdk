//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

struct FakeValueWrapper<T> {
    
    let value: T
    
    func unwrap<U>() throws -> U {
        guard let value = value as? U else {
            throw FakedError.typeMismatch("Expected type: \(T.self) doesn't match with value type: \(U.self)")
        }
        return value
    }
    
}

func wrap<T>(_ value: T) -> FakeValueWrapper<T> {
    return FakeValueWrapper(value: value)
}
