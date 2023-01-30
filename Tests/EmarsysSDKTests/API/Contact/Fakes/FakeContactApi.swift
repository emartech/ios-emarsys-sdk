//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation
@testable import EmarsysSDK

struct FakeContactApi: ContactApi, Faked, Equatable {

    var instanceId: String = UUID().description
    
    let linkContact = "linkContact"
    let linkAuthenticatedContact = "linkAuthenticatedContact"
    let unlinkContact = "unlinkContact"
    
    func linkContact(contactFieldId: Int, contactFieldValue: String) async throws {
        return try self.handleCall(\.linkContact, params: contactFieldId, contactFieldValue)
    }
    
    func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async throws {
        return try self.handleCall(\.linkAuthenticatedContact, params: contactFieldId, openIdToken)
    }
    
    func unlinkContact() async throws {
        return try self.handleCall(\.unlinkContact)
    }
    
    static func == (lhs: FakeContactApi, rhs: FakeContactApi) -> Bool {
        return lhs.instanceId == rhs.instanceId
    }
    
}
