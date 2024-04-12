//
//
// Copyright © 2024. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

class PersistentList<Element: Codable & Equatable>: RandomAccessCollection & MutableCollection & Sequence & RangeReplaceableCollection, Equatable {
    
    private var id: String?
    private var storage: SecureStorage?
    private var sdkLogger: SdkLogger?
    
    private var elements: [Element]
    
    typealias Element = Element
    typealias Index = Int
    
    init(id: String, storage: SecureStorage, sdkLogger: SdkLogger) {
        self.id = id
        self.storage = storage
        self.sdkLogger = sdkLogger
        do {
            if let elements: [Element] = try storage.get(key: id, accessGroup: nil) {
                self.elements = elements
            } else {
                self.elements = [Element]()
                persist()
            }
        } catch {
            elements = [Element]()
            persist()
            Task { @SdkActor in
                let logEntry = LogEntry(topic: "PersistentList",
                                        data: ["message": "Retrieving list failed.",
                                               "error" : error.localizedDescription]
                )
                self.sdkLogger?.log(logEntry: logEntry, level: .error)
            }
        }
    }
    
    init(id: String, storage: SecureStorage, sdkLogger: SdkLogger, elements: [Element]) {
        self.id = id
        self.storage = storage
        self.sdkLogger = sdkLogger
        self.elements = elements
        persist()
    }
    
    required init() {
        self.id = nil
        self.storage = nil
        self.sdkLogger = nil
        self.elements = [Element]()
        assert(false, "Init called unintentionally.")
    }
    
    var startIndex: Int {
        elements.startIndex
    }
    
    var endIndex: Int {
        elements.endIndex
    }
    
    func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Element == C.Element {
        let elements = self.elements
        self.elements.replaceSubrange(subrange, with: newElements)
        persist() {
            self.elements = elements
        }
    }
    
    func removeAll(keepingCapacity keepCapacity: Bool) {
        self.elements.removeAll(keepingCapacity: keepCapacity)
        persist()
    }
    
    subscript(position: Index) -> Element {
        get {
            return elements[position]
        }
        set {
            let elements = self.elements
            self.elements[position] = newValue
            persist() {
                self.elements = elements
            }
        }
    }
    
    static func == (lhs: PersistentList<Element>, rhs: PersistentList<Element>) -> Bool {
        return lhs.elements == rhs.elements
    }
    
    private func persist(_ onError: (() -> ())? = nil) {
        if let storage = self.storage, let id = self.id, let logger = self.sdkLogger {
            do {
                try storage.put(item: self.elements, key: id, accessGroup: nil)
            } catch {
                if let onError {
                    onError()
                }
                Task { @SdkActor in
                    let logEntry = LogEntry(topic: "PersistentList",
                                            data: ["message": "persisting list failed.",
                                                   "error" : error.localizedDescription])
                    logger.log(logEntry: logEntry, level: .error)
                }
            }
        }
    }
    
}
