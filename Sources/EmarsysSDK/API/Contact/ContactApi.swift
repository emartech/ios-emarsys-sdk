//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
protocol ContactApi {
    
    func linkContact(contactFiledId: Int, contactFieldValue: String) async throws
    
    func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async throws
    
    func unlinkContact() async throws
    
}
