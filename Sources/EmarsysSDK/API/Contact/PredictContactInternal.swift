//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

struct PredictContactInternal: ActivatableContactApi {
    
    let contactContext: ContactContext
    let contactClient: ContactClient
    
    func linkContact(contactFieldId: Int, contactFieldValue: String) async throws {
        try await contactClient.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue, openIdToken: nil)
    }
    
    func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async throws {
        try await contactClient.linkContact(contactFieldId: contactFieldId, contactFieldValue: nil, openIdToken: openIdToken)
    }
    
    func unlinkContact() async throws {
       try await contactClient.unlinkContact()
    }
    
    func activated() async throws {
       try await self.sendGatheredCalls()
    }
    
    private func sendGatheredCalls() async throws {
        for call in contactContext.calls {
            switch call {
            case .linkContact(let contactFieldId, let contactFieldValue):
                try await contactClient.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue, openIdToken: nil)
            case .linkAuthenticatedContact(let contactFieldId, let openIdToken):
                try await contactClient.linkContact(contactFieldId: contactFieldId, contactFieldValue: nil, openIdToken: openIdToken)
            case .unlinkContact:
               try await contactClient.unlinkContact()
            }
        }
    }
}
