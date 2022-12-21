//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct FetchRemoteConfigState: State {
    
    var context: StateContext?
    
    let networkClient: DefaultNetworkClient
    let applicationCode: String
    let defaultValues: DefaultValues
    let crypto: Crypto
    
    var name = SetupState.fetchRemoteConfig.rawValue
    
    func prepare() {
    }
    
    func activate() async {
        let signatureUrlString = defaultValues.remoteConfigBaseUrl.appending("/signature/\(applicationCode)")
        let remoteConfigUrlString = defaultValues.remoteConfigBaseUrl.appending("/\(applicationCode)")
        guard let signatureUrl = URL(string: signatureUrlString) else {
            try? await self.context?.switchTo(stateName: SetupState.registerClient.rawValue)
            return
        }
        guard let remoteConfigUrl = URL(string: remoteConfigUrlString) else {
            try? await self.context?.switchTo(stateName: SetupState.registerClient.rawValue)
            return
        }
        let signatureRequest = URLRequest.create(url: signatureUrl)
        let remoteConfigRequest = URLRequest.create(url: remoteConfigUrl)
        
        let remoteConfigData: Data = await networkClient.send(request: remoteConfigRequest)
        let signature: Data = await networkClient.send(request: signatureRequest)
        let verified = crypto.verify(content: remoteConfigData, signature: signature)
        if verified {
            do {
                let remoteConfig = try JSONSerialization.jsonObject(with: remoteConfigData)
                //
            } catch {
                
            }
        }
    }
    
    func relax() {
    }
    
}
