//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct LoggingEvent: EventInstance {
    
    let logger: SdkLogger
    
    func trackCustomEvent(name: String, attributes: [String: String]?) async throws {
        var params: [String: Any] = ["name": name]
        params["attributes"] = attributes
        let entry = LogEntry.createMethodNotAllowedEntry(source: self,
                                                         params: params)
        logger.log(logEntry: entry, level: .debug)
    }
}