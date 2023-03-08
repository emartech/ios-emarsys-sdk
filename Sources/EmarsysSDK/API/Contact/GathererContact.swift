//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
class GathererContact: ContactInstance {
    
    var contactContext: ContactContext
    
    init(contactContext: ContactContext) {
        self.contactContext = contactContext
    }
    
    func linkContact(contactFieldId: Int, contactFieldValue: String) async throws {
        contactContext.calls.append(.linkContact(contactFieldId, contactFieldValue))
    }
    
    func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async throws {
        contactContext.calls.append(.linkAuthenticatedContact(contactFieldId, openIdToken))
    }
    
    func unlinkContact() async throws {
        contactContext.calls.append(.unlinkContact)        
    }
    
}
