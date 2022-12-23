//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

class Contact: ContactApi {
    
    let loggingContact: LoggingContact
    let gathererContact: GathererContact
    let contactInternal: ContactInternal
    
    var active: ContactApi
    var apiState: ApiState {
        didSet {
            switch apiState {
            case .active:
                self.active = contactInternal
            case .onHold:
                self.active = gathererContact
            case .inactive:
                self.active = loggingContact
            }
        }
    }
    
    init(loggingContact: LoggingContact, gathererContact: GathererContact, contactInternal: ContactInternal, apiState: ApiState) {
        self.loggingContact = loggingContact
        self.gathererContact = gathererContact
        self.contactInternal = contactInternal
        self.apiState = apiState
        self.active = loggingContact
    }
    
    func linkContact(contactFiledId: Int, contactFieldValue: String) async throws {
        try await self.active.linkContact(contactFiledId: contactFiledId, contactFieldValue: contactFieldValue)
    }
    
    func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async throws {
        try await self.active.linkAuthenticatedContact(contactFieldId: contactFieldId, openIdToken: openIdToken)
    }
    
    func unlinkContact() async throws {
        try await self.active.unlinkContact()
    }
    
}
