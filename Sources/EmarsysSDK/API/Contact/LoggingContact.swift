//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

struct LoggingContact: ActivatableContactApi {
    let logger: SDKLogger
    
    func linkContact(contactFieldId: Int, contactFieldValue: String) async throws {
        let entry = LogEntry.createMethodNotAllowedEntry(source: self,
                                                         params: ["contactFieldId": contactFieldId,
                                                                  "contactFieldValue": contactFieldValue])
        logger.log(logEntry: entry, level: .debug)
    }
    
    func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async throws {
        let entry = LogEntry.createMethodNotAllowedEntry(source: self,
                                                         params: ["contactFieldId": contactFieldId,
                                                                  "openIdToken": openIdToken])
        logger.log(logEntry: entry, level: .debug)
    }
    
    func unlinkContact() async throws {
        let entry = LogEntry.createMethodNotAllowedEntry(source: self)
        logger.log(logEntry: entry, level: .debug)
    }
    
}
