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
    private var dependencyContainer: TestDependencyContainer

    var wrappedValue: U {
        get {
            return dependencyContainer[keyPath: keyPath] as! U
        }
        set {
            dependencyContainer[keyPath: keyPath] = newValue as! T
        }
    }

    init(_ keyPath: WritableKeyPath<TestDependencyContainer, T>) {
        if let container = DependencyInjection.container as? TestDependencyContainer {
            dependencyContainer = container
        } else {
            let testContainer = TestDependencyContainer()
            DependencyInjection.tearDown()
            DependencyInjection.setup(testContainer)
            dependencyContainer = testContainer
        }
        self.keyPath = keyPath
    }
}
