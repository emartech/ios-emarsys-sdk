//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
@testable import EmarsysSDK

@SdkActor
@propertyWrapper
struct Inject<T, U> {

    private let keyPath: WritableKeyPath<TestDependencyContainer, T>
    private var dependencyContainer: TestDependencyContainer {
        get {
            var result: TestDependencyContainer!
            if let container = DependencyInjection.container as? TestDependencyContainer {
                result = container
            } else {
                let testContainer = TestDependencyContainer()
                DependencyInjection.tearDown()
                DependencyInjection.setup(testContainer)
                result = testContainer
            }
            return result
        }
    }

    var wrappedValue: U {
        get {
            return dependencyContainer[keyPath: keyPath] as! U
        }
        set {
            var dc = self.dependencyContainer
            dc[keyPath: keyPath] = newValue as! T
        }
    }

    init(_ keyPath: WritableKeyPath<TestDependencyContainer, T>) {
        self.keyPath = keyPath
    }
    
}
