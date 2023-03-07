//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
import Combine

@SdkActor
class Contact: Api, ContactApi {
    
    let loggingContact: ActivatableContactApi
    let gathererContact: ActivatableContactApi
    let contactInternal: ActivatableContactApi
    let predictContactInternal: ActivatableContactApi
    
    var active: ActivatableContactApi {
        willSet {
            Task {
                try await newValue.activated()
            }
        }
    }
    var sdkContext: SdkContext
    
    var cancellables = Set<AnyCancellable>()
    
    init(loggingContact: ActivatableContactApi,
         gathererContact: ActivatableContactApi,
         contactInternal: ActivatableContactApi,
         predictContactInternal: ActivatableContactApi,
         sdkContext: SdkContext) {
        self.loggingContact = loggingContact
        self.gathererContact = gathererContact
        self.contactInternal = contactInternal
        self.predictContactInternal = predictContactInternal
        self.sdkContext = sdkContext
        self.active = loggingContact
        
        sdkContext.$sdkState.sink { [unowned self] state in
            self.setActiveInstance(state: state, features: sdkContext.features)
        }.store(in: &cancellables)
        
        sdkContext.$features.sink { [unowned self] features in
            self.setActiveInstance(state: sdkContext.sdkState, features: features)
        }.store(in: &cancellables)
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
        switch state {
        case .active:
            if features.contains(Feature.mobileEngage) {
                self.active = contactInternal
            } else if features.contains(Feature.predict) {
                self.active = predictContactInternal
            }
        case .onHold:
            self.active = gathererContact
        case .inactive:
            self.active = loggingContact
        }
    }
}
