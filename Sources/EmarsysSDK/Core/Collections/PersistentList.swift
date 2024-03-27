//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

class PersistentList<T: Storable>: ModifiableCollection {
    var id: String
    private var storage: SecureStorage
    private(set) var elements: [T]
    var sdkLogger: SdkLogger
    
    typealias Index = Int
    typealias Element = T
    
    init(id: String, storage: SecureStorage, sdkLogger: SdkLogger) throws {
        self.id = id
        self.storage = storage
        self.sdkLogger = sdkLogger
        if let elements: [T] = try storage.get(key: id, accessGroup: nil) {
            self.elements = elements
        }
        else {
            self.elements = []
            persist()
        }
    }
    
    init(id: String, storage: SecureStorage, elements: [T], sdkLogger: SdkLogger) throws {
        self.id = id
        self.storage = storage
        self.elements = elements
        self.sdkLogger = sdkLogger
        persist()
    }
    
    var startIndex: Int {
        get {
            return elements.startIndex
        }
    }
    
    var endIndex: Int {
        get {
            return elements.endIndex
        }
    }
    
    subscript(position: Index) -> Element {
        get {
            return elements[position]
        }
        
        set {
            var newElements = elements
            newElements[position] = newValue
            persistAndSet(newElements)
        }
    }
    
    func index(after i: Int) -> Int {
        elements.index(after: i)
    }
    
    func append(_ newElement: Element) {
        var newElements = elements
        newElements.append(newElement)
        persistAndSet(newElements)
    }
    
    private func persist() {
        persistAndSet(elements)
    }
    
    private func persistAndSet(_ newElements: [Element]) {
        do {
            try storage.put(item: newElements, key: id, accessGroup: nil)
            elements = newElements
        } catch {
            let logEntry = LogEntry(topic: "PersistentList",
                                    data: ["message": "persisting list failed.",
                                           "error" : error.localizedDescription]
            )
            sdkLogger.log(logEntry: logEntry, level: .error)
        }
    }
    
}
