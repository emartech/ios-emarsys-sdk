//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

class GathererContact: ContactApi {
    
    var contactContext: ContactContext
    
    init(contactContext: ContactContext) {
        self.contactContext = contactContext
    }
    
    func linkContact(contactFieldId: Int, contactFieldValue: String) async throws {
        contactContext.calls.append(.linkContact(contactFieldId, contactFieldValue))
        //TODO: add call to callgatherer dependency
    }
    
    func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async throws {
        contactContext.calls.append(.linkAuthenticatedContact(contactFieldId, openIdToken))
        //TODO: add call to callgatherer dependency
    }
    
    func unlinkContact() async throws {
        contactContext.calls.append(.unlinkContact)
        //TODO: add call to callgatherer dependency        
    }
    
}
