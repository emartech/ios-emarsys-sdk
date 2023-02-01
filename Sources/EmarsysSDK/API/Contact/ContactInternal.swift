//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

struct ContactInternal: ContactApi {
    
    let contactContext: ContactContext
    let contactClient: ContactClient
    
    func linkContact(contactFieldId: Int, contactFieldValue: String) async throws {
        try! await contactClient.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue, openIdToken: nil) // TODO: handle error
    }
    
    func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async throws {
        try! await contactClient.linkContact(contactFieldId: contactFieldId, contactFieldValue: nil, openIdToken: openIdToken) // TODO: handle error
    }
    
    func unlinkContact() async throws {
       try await contactClient.unlinkContact()
    }

}
