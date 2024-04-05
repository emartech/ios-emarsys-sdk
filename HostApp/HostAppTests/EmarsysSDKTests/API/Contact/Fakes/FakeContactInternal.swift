//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation
@testable import EmarsysSDK
import mimic

struct FakeContactInternal: ContactInstance, Mimic {
    
    let fnLinkContact = Fn<()>()
    let fnLinkAuthenticatedContact = Fn<()>()
    let fnUnlinkContact = Fn<()>()
    
    func linkContact(contactFieldId: Int, contactFieldValue: String) async throws {
        return try self.fnLinkContact.invoke(params: contactFieldId, contactFieldValue)
    }
    
    func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async throws {
        return try self.fnLinkAuthenticatedContact.invoke(params: contactFieldId, openIdToken)
    }
    
    func unlinkContact() async throws {
        return try self.fnUnlinkContact.invoke()
    }
    
}
