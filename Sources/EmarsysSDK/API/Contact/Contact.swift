//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

class Contact: Api, ContactApi {

    let loggingContact: ContactApi
    let gathererContact: ContactApi
    let contactInternal: ContactApi

    var active: ContactApi
    var sdkContext: SdkContext

    init(loggingContact: ContactApi,
         gathererContact: ContactApi,
         contactInternal: ContactApi,
         sdkContext: SdkContext) {
        self.loggingContact = loggingContact
        self.gathererContact = gathererContact
        self.contactInternal = contactInternal
        self.sdkContext = sdkContext
        self.active = loggingContact
        let _ = sdkContext.$sdkState.sink { [unowned self] state in
            self.setActiveInstance(state: state, features: sdkContext.features)
        }
        let _ = sdkContext.$features.sink { [unowned self] features in
            self.setActiveInstance(state: sdkContext.sdkState, features: features)
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
    
    private func setActiveInstance(state: SdkState, features: [Feature]) {
        guard features.contains(where: { feature in
            feature == Feature.everything
        }) else {
            self.active = loggingContact
            return
        }
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
