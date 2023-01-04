//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

@SdkActor
struct LinkContactState: State {
    
    let contactClient: ContactClient
    let secStore: SecStore
    
    var name = SetupState.linkContact.rawValue
    
    var nextStateName: String? = nil
    
    func prepare() {
    }
    
    func active() async throws {
        if secStore["contactToken"]?.toString() == nil {
            await contactClient.unlinkContact()
        }
    }
    
    func relax() {
    }
    
}
