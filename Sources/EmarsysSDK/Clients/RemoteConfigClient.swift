//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct RemoteConfigClient {
    
    let networkClient: NetworkClient
    let configContext: SdkContext
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
        let signatureUrlString = defaultValues.remoteConfigBaseUrl.appending("/signature/\(configContext.config?.applicationCode)")
        guard let signatureUrl = URL(string: signatureUrlString) else {
            throw Errors.urlCreationFailed("urlCreationFailed".localized(with: signatureUrlString))
        }
        let signatureRequest = URLRequest.create(url: signatureUrl)
        
        let result: Result<(response: HTTPURLResponse, data: Data), Error> = await networkClient.send(request: signatureRequest)
        var signature: Data
        switch result {
        case .success(let response):
            signature = response.data
        case .failure(let error):
            // TODO: error handling
            print("error: \(error)")
            throw error
        }
        return signature
    }
    
    private func fetchConfig() async throws -> Data {
        let remoteConfigUrlString = defaultValues.remoteConfigBaseUrl.appending("/\(configContext.config?.applicationCode)")
        guard let remoteConfigUrl = URL(string: remoteConfigUrlString) else {
            throw Errors.urlCreationFailed("urlCreationFailed".localized(with: remoteConfigUrlString))
        }
        let remoteConfigRequest = URLRequest.create(url: remoteConfigUrl)
        
        let result: Result<(response: HTTPURLResponse, data: Data), Error> = await networkClient.send(request: remoteConfigRequest)
        var remoteConfigData: Data
        switch result {
        case .success(let response):
            remoteConfigData = response.data
        case .failure(let error):
            // TODO: error handling
            print("error: \(error)")
            throw error
        }
        return remoteConfigData
    }
    
}
