//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

struct DependencyInjection {
    
    static var container: DependencyContainer?

    static func setup(_ dependencyContainer: DependencyContainer) {
        if(container == nil) {
            container = dependencyContainer
        }
    }

    static func teardown() {
        self.container = nil
    }
}
