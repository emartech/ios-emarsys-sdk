//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

@SdkActor
struct LinkContactState: State {
    
    let contactClient: ContactClient
    let secStore: SecureStorage
    
    var name = SetupState.linkContact.rawValue
    
    var nextStateName: String? = nil
    
    func prepare() {
    }
    
    func active() async throws {
        let contactToken: String? = try secStore.get(key: "contactToken")
        if contactToken == nil {
            try await contactClient.unlinkContact()
        }
    }
    
    func relax() {
    }
    
}
