//
// Copyright (c) 2022 Emarsys. All rights reserved.
//

import Foundation
import os

struct LogEntry {
    let topic: String
    let data: [String: Any]
    let hideSensitiveData: Bool = false
}

extension LogEntry {
    
    static func createMethodNotAllowedEntry<T>(source: T, functionName: String = #function, params: [String: Any]? = nil) -> LogEntry {
      var data: [String: Any] = [
                    "className": String(describing: source.self),
                    "methodName": functionName
                ]
        
        if params != nil {
            data["parameters"] = params
        }

        return LogEntry(topic: "log_method_not_allowed", data: data)
    }
}
