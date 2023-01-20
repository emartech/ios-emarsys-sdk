//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

typealias FakableFunction = (_ invocationNumber: Int, _ args: Any?...) -> (Any?)

protocol Fakable {

    func when(_ functionName: String, function: @escaping FakableFunction)
    
    func assertProp<T: Equatable>(_ propName: String, expectedValue: T) throws -> Bool
    
    func tearDown()
    
    func props() -> [String: Any?]
    
    func handleCall(_ functionName: String, args: Any?...) -> Any?
}


extension Fakable {
    
    func when(_ functionName: String, function: @escaping FakableFunction) {
        let instanceId = instanceId()
        FunctionHolder.add(instanceId: instanceId, functionName: functionName, functionDetail: (0, function))
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
        FunctionHolder.remove(instanceId: instanceId())
    }
    
    func props() -> [String: Any?] {
        let selfMirror = Mirror(reflecting: self)
        return selfMirror.children.reduce([String: Any?]()) { partialResult, child in
            var props = partialResult
            props[child.label!] = child.value
            return props
        }
    }
    
    func handleCall(_ functionName: String = #function, args: Any?...) -> Any? {
        let instanceId = instanceId()
        guard let functionDetail = FunctionHolder.get(instanceId: instanceId, functionName: functionName) else {
            return nil
        }
        var funcInvocationCount = functionDetail.0
        funcInvocationCount += 1
        let function = functionDetail.1
        FunctionHolder.add(instanceId: instanceId, functionName: functionName, functionDetail: (funcInvocationCount, function))
        return function(funcInvocationCount, args)
    }
    
    private func instanceId() -> String {
        return String(format: "%p", unsafeBitCast(self, to: Int.self))
    }
    
}

fileprivate struct FunctionHolder {
    
    private static var functionDetails = [String: [String: (Int, FakableFunction)]]()
    
    static func add(instanceId: String, functionName: String, functionDetail: (Int, FakableFunction)) {
        FunctionHolder.functionDetails[instanceId] = [functionName: functionDetail]
    }
    
    static func get(instanceId: String, functionName: String) -> (Int, FakableFunction)? {
        let functionDetails = FunctionHolder.functionDetails[instanceId]
        guard let key = functionDetails?.keys.first(where: { functionName.hasPrefix($0) }) else {
            return nil
        }
        return functionDetails?[key]
    }
    
    static func remove(instanceId: String) {
        FunctionHolder.functionDetails[instanceId] = nil
    }
    
}
