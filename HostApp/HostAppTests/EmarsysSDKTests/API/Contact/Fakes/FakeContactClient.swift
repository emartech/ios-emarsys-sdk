//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK
import mimic

struct FakeContactClient: ContactClient, Mimic {
    
    let fnLinkContact = Fn<()>()
    let fnUnlinkContact = Fn<()>()
    
    func linkContact(contactFieldId: Int, contactFieldValue: String? = nil, openIdToken: String? = nil) async throws {
        return try fnLinkContact.invoke(params: contactFieldId, contactFieldValue, openIdToken)
    }
    
    func unlinkContact() async {
        return try! fnUnlinkContact.invoke()
    }
}
