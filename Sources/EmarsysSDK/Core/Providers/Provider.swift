//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

protocol Provider {
    
    associatedtype Value
    
    func provide() async -> Value
    
}
