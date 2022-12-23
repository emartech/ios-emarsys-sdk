//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct RemoteConfigClient {
    
    let networkClient: NetworkClient
    let applicationCode: String
    let defaultValues: DefaultValues
    let crypto: Crypto
    
    func applyActiveConfig() async throws {
        let configData = try await fetchConfig()
        let signature = try await fetchSignature()
        let verified = crypto.verify(content: configData, signature: signature)
        if verified {
            let remoteConfig = try JSONSerialization.jsonObject(with: configData)
            //TODO: update defaults with remoteConfig
        }
    }
    
    private func fetchSignature() async throws -> Data {
        let signatureUrlString = defaultValues.remoteConfigBaseUrl.appending("/signature/\(applicationCode)")
        guard let signatureUrl = URL(string: signatureUrlString) else {
            throw Errors.urlCreationFailed("urlCreationFailed".localized(with: signatureUrlString))
        }
        let signatureRequest = URLRequest.create(url: signatureUrl)
        
        let signature: Data = await networkClient.send(request: signatureRequest)
        
        return signature
    }
    
    private func fetchConfig() async throws -> Data {
        let remoteConfigUrlString = defaultValues.remoteConfigBaseUrl.appending("/\(applicationCode)")
        guard let remoteConfigUrl = URL(string: remoteConfigUrlString) else {
            throw Errors.urlCreationFailed("urlCreationFailed".localized(with: remoteConfigUrlString))
        }
        let remoteConfigRequest = URLRequest.create(url: remoteConfigUrl)
        
        let remoteConfigData: Data = await networkClient.send(request: remoteConfigRequest)
        
        return remoteConfigData
    }
    
}
