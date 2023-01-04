//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

class Contact: Api, ContactApi {
    
    let loggingContact: LoggingContact
    let gathererContact: GathererContact
    let contactInternal: ContactInternal
    
    var active: ContactApi
    var sdkContext: SdkContext
    
    init(loggingContact: LoggingContact, gathererContact: GathererContact, contactInternal: ContactInternal, sdkContext: SdkContext) {
        self.loggingContact = loggingContact
        self.gathererContact = gathererContact
        self.contactInternal = contactInternal
        self.sdkContext = sdkContext
        self.active = loggingContact
        sdkContext.$sdkState.sink { state in // TODO: handle warning
            switch state {
            case .active:
                self.active = contactInternal
            case .onHold:
                self.active = gathererContact
            case .inactive:
                self.active = loggingContact
            }
        }
    }
    
    func linkContact(contactFieldId: Int, contactFieldValue: String) async throws {
        try await self.active.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue)
    }
    
    func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async throws {
        try await self.active.linkAuthenticatedContact(contactFieldId: contactFieldId, openIdToken: openIdToken)
    }
    
    func unlinkContact() async throws {
        try await self.active.unlinkContact()
    }
    
}
