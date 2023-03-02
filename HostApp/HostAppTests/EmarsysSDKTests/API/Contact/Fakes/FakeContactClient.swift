//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK

struct FakeContactClient: ContactClient, Faked {
    
    var faker = Faker()
    
    let linkContact = "linkContact"
    let unlinkContact = "unlinkContact"
    
    func linkContact(contactFieldId: Int, contactFieldValue: String? = nil, openIdToken: String? = nil) async throws {
        return try handleCall(\.linkContact, params: contactFieldId, contactFieldValue, openIdToken)
    }
    
    func unlinkContact() async {
        return try! handleCall(\.unlinkContact)
    }
}
