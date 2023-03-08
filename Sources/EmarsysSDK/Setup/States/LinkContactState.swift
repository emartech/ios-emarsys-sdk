//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

@SdkActor
struct LinkContactState: State {
    
    let contactClient: ContactClient
    let secureStorage: SecureStorage
    
    var name = SetupState.linkContact.rawValue
    
    func prepare() {
    }
    
    func active() async throws {
        let contactToken: String? = secureStorage[Constants.Contact.contactToken]
        if contactToken == nil {
            let contactFieldId: Int? = secureStorage[Constants.Contact.contactFieldId]
            let contactFieldValue: String? = secureStorage[Constants.Contact.contactFieldValue]
            let openIdToken: String? = secureStorage[Constants.Contact.openIdToken]
            if (contactFieldId != nil && contactFieldValue != nil) || (contactFieldId != nil && openIdToken != nil) {
                try await contactClient.linkContact(contactFieldId: contactFieldId!, contactFieldValue: contactFieldValue, openIdToken: openIdToken)
            } else {
                try await contactClient.unlinkContact()
            }
        }
    }
    
    func relax() {
    }
    
}
