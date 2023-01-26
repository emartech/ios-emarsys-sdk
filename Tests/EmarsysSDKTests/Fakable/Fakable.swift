//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

typealias FakableFunction = (_ invocationCount: Int, _ params: [FakeValueWrapper<Any?>]) throws -> (Any?)

protocol Fakable {
    
    var instanceId: String { get }
    
    func when(_ fnName: String, function: @escaping FakableFunction)
    func when(_ fnKeyPath: KeyPath<Self, String>, function: @escaping FakableFunction)
    
    func assertProp<T: Equatable>(_ propName: String, expectedValue: T) throws -> Bool
    
    func tearDown()
    
    func props() -> [String: Any?]
    
    func handleCall<T>(_ fnName: String, params: Any?...) throws -> T
    func handleCall<T>(_ fnKeyPath: KeyPath<Self, String>, params: Any?...) throws -> T
    func handleCall<T>(_ fnName: String) throws -> T
    func handleCall<T>(_ fnKeyPath: KeyPath<Self, String>) throws -> T
}


extension Fakable {
    
    func when(_ fnName: String, function: @escaping FakableFunction) {
        FunctionHolder.add(instanceId: instanceId, functionName: fnName, functionDetail: (0, function))
    }
    
    func when(_ fnKeyPath: KeyPath<Self, String>, function: @escaping FakableFunction) {
        let fnName = self[keyPath: fnKeyPath]
        when(fnName, function: function)
    }
    
    func assertProp<T>(_ propName: String, expectedValue: T) throws -> Bool where T: Equatable {
        let selfMirror = Mirror(reflecting: self)
        guard let child = selfMirror.children.first( where: { $0.label == propName }) else {
            throw FakableError.noPropertyFound("No property found with name: \(propName)")
        }
        guard let value = child.value as? T else {
            let valueType = type(of: child.value)
            throw FakableError.typeMismatch("Expected type: \(T.self) doesn't match with value type: \(valueType)")
        }
        guard expectedValue == value else {
            throw FakableError.assertionFailed("Expected value: \(expectedValue) doesn't equal to: \(value)")
        }
        return true
    }
    
    func tearDown() {
        FunctionHolder.remove(instanceId: instanceId)
    }
    
    func props() -> [String: Any?] {
        let selfMirror = Mirror(reflecting: self)
        return selfMirror.children.reduce([String: Any?]()) { partialResult, child in
            var props = partialResult
            props[child.label!] = child.value
            return props
        }
    }
    
    func handleCall<T>(_ fnName: String = #function, params: Any?...) throws -> T {
        guard let functionDetail = FunctionHolder.get(instanceId: instanceId, functionName: fnName) else {
            throw FakableError.missingFunction("No preregistered function found for function name: \(fnName)")
        }
        
        var invocationCount = functionDetail.0
        invocationCount += 1
        let function = functionDetail.1
        FunctionHolder.add(instanceId: instanceId, functionName: fnName, functionDetail: (invocationCount, function))
        
        var wrappedParams = [FakeValueWrapper<Any?>]()
        
        if params.count > 0 {
            wrappedParams = params.map { param in
                return wrap(param)
            }
        }
        
        let functionResult = try function(invocationCount, wrappedParams)
        guard let result = functionResult as? T else {
            throw FakableError.typeMismatch("Result type: \(T.self) doesn't match with stored funciton result type: \(type(of: functionResult))")
        }
        
        return result
    }
    
    func handleCall<T>(_ fnKeyPath: KeyPath<Self, String>, params: Any?...) throws -> T {
        let fnName = self[keyPath: fnKeyPath]
        return try handleCall(fnName, params: params)
    }

    func handleCall<T>(_ fnName: String = #function) throws -> T {
        return try handleCall(fnName, params: nil)
    }
    
    func handleCall<T>(_ fnKeyPath: KeyPath<Self, String>) throws -> T {
        let fnName = self[keyPath: fnKeyPath]
        return try handleCall(fnName, params: nil)
    }
    
}

fileprivate struct FunctionHolder {
    
    private static var functionDetails = [String: [String: (Int, FakableFunction)]]()
    
    static func add(instanceId: String, functionName: String, functionDetail: (Int, FakableFunction)) {
        FunctionHolder.functionDetails[instanceId] = [functionName: functionDetail]
    }
    
    static func get(instanceId: String, functionName: String) -> (Int, FakableFunction)? {
        let functionDetails = FunctionHolder.functionDetails[instanceId]
        return functionDetails?[functionName]
    }
    
    static func remove(instanceId: String) {
        FunctionHolder.functionDetails[instanceId] = nil
    }
    
}
