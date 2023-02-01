//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

typealias FakedFunction = (_ invocationCount: Int,
                             _ params: [FakeValueWrapper<Any?>]) throws -> (Any?)

protocol Faked: Equatable {
    
    var instanceId: String { get }
    
    func when(_ fnName: String,
              function: @escaping FakedFunction)
    func when(_ fnKeyPath: KeyPath<Self, String>,
              function: @escaping FakedFunction)
    
    func handleCall<ReturnType>(_ fnName: String,
                                params: Any?...) throws -> ReturnType
    func handleCall<ReturnType>(_ fnKeyPath: KeyPath<Self, String>,
                                params: Any?...) throws -> ReturnType
    func handleCall<ReturnType>(_ fnName: String) throws -> ReturnType
    func handleCall<ReturnType>(_ fnKeyPath: KeyPath<Self, String>) throws -> ReturnType
    
    func props() -> [String: Any?]
    
    func assertProp<T: Equatable>(_ propName: String,
                                  expectedValue: T) throws -> Bool
    
    func tearDown()

}

extension Faked {
    
    func when(_ fnName: String, function: @escaping FakedFunction) {
        FakedFunctionHolder.add(instanceId: instanceId, functionName: fnName, functionDetail: (0, function))
    }
    
    func when(_ fnKeyPath: KeyPath<Self, String>, function: @escaping FakedFunction) {
        let fnName = self[keyPath: fnKeyPath]
        when(fnName, function: function)
    }
    
    func handleCall<ReturnType>(_ fnName: String = #function, params: Any?...) throws -> ReturnType {
        guard let functionDetail = FakedFunctionHolder.get(instanceId: instanceId, functionName: fnName) else {
            throw FakedError.missingFunction("No preregistered function found for function name: \(fnName)")
        }
        
        var invocationCount = functionDetail.0
        invocationCount += 1
        let function = functionDetail.1
        FakedFunctionHolder.add(instanceId: instanceId, functionName: fnName, functionDetail: (invocationCount, function))
        
        var wrappedParams = [FakeValueWrapper<Any?>]()
        
        if params.count > 0 {
            wrappedParams = params.map { param in
                return wrap(param)
            }
        }

        let functionResult = try function(invocationCount, wrappedParams)
        guard let result = functionResult as? ReturnType else {
            throw FakedError.typeMismatch("Result type: \(ReturnType.self) doesn't match with stored function result type: \(type(of: functionResult))")
        }
        
        return result
    }
    
    func handleCall<ReturnType>(_ fnKeyPath: KeyPath<Self, String>, params: Any?...) throws -> ReturnType {
        let fnName = self[keyPath: fnKeyPath]
        return try handleCall(fnName, params: params)
    }

    func handleCall<ReturnType>(_ fnName: String = #function) throws -> ReturnType {
        return try handleCall(fnName, params: nil)
    }
    
    func handleCall<ReturnType>(_ fnKeyPath: KeyPath<Self, String>) throws -> ReturnType {
        let fnName = self[keyPath: fnKeyPath]
        return try handleCall(fnName, params: nil)
    }
    
    func props() -> [String: Any?] {
        let selfMirror = Mirror(reflecting: self)
        return selfMirror.children.reduce([String: Any?]()) { partialResult, child in
            var props = partialResult
            props[child.label!] = child.value
            return props
        }
    }
    
    func assertProp<T>(_ propName: String, expectedValue: T) throws -> Bool where T: Equatable {
        let selfMirror = Mirror(reflecting: self)
        guard let child = selfMirror.children.first( where: { $0.label == propName }) else {
            throw FakedError.noPropertyFound("No property found with name: \(propName)")
        }
        guard let value = child.value as? T else {
            let valueType = type(of: child.value)
            throw FakedError.typeMismatch("Expected type: \(T.self) doesn't match with value type: \(valueType)")
        }
        guard expectedValue == value else {
            throw FakedError.assertionFailed("Expected value: \(expectedValue) doesn't equal to: \(value)")
        }
        return true
    }
    
    func tearDown() {
        FakedFunctionHolder.remove(instanceId: instanceId)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.instanceId == rhs.instanceId
    }
    
}

fileprivate struct FakedFunctionHolder {
    
    private static var functionDetails = [String: [String: (Int, FakedFunction)]]()
    
    static func add(instanceId: String, functionName: String, functionDetail: (Int, FakedFunction)) {
        if var functionDetails = FakedFunctionHolder.functionDetails[instanceId] {
            functionDetails[functionName] = functionDetail
            FakedFunctionHolder.functionDetails[instanceId] = functionDetails
        } else {
            FakedFunctionHolder.functionDetails[instanceId] = [functionName: functionDetail]
        }
    }
    
    static func get(instanceId: String, functionName: String) -> (Int, FakedFunction)? {
        let functionDetails = FakedFunctionHolder.functionDetails[instanceId]
        return functionDetails?[functionName]
    }
    
    static func remove(instanceId: String) {
        FakedFunctionHolder.functionDetails[instanceId] = nil
    }
    
}
