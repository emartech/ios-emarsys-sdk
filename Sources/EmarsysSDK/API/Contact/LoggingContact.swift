//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

struct LoggingContact: ContactApi {
    
    func linkContact(contactFieldId: Int, contactFieldValue: String) async throws {
        // log call
    }
    
    func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async throws {
        // log call
    }
    
    func unlinkContact() async throws {
        // log call
    }
    
}
