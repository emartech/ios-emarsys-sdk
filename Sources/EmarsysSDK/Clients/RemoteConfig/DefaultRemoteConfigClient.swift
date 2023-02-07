import Foundation

@SdkActor
struct DefaultRemoteConfigClient: RemoteConfigClient {
    let networkClient: NetworkClient
    let sdkContext: SdkContext
    let crypto: Crypto
    let logger: SdkLogger

    func fetchRemoteConfig() async throws -> Dictionary<String, String>? {
        guard let configData: Data = try await fetchConfig() else {
            return nil
        }
        guard let signature: Data = try await fetchSignature() else {
            return nil
        }
        let verified = crypto.verify(content: configData, signature: signature)
        var remoteConfig: Dictionary<String, String>? = nil
        if verified {
            remoteConfig = try JSONSerialization.jsonObject(with: configData) as! Dictionary<String, String>
        }
        return remoteConfig
    }

    private func fetchSignature() async throws -> Data? {
        let signatureUrlString = try sdkContext.createUrl(\.remoteConfigBaseUrl, version: "", withAppCode: false, path: "signature/\(sdkContext.config?.applicationCode ?? "")")

        let signatureRequest = URLRequest.create(url: signatureUrlString)

        let result: (Data, HTTPURLResponse) = try await networkClient.send(request: signatureRequest)
        if result.1.isOk() {
            return result.0
        } else {
            return nil
        }
    }

    private func fetchConfig() async throws -> Data? {
        let remoteConfigUrlString = try sdkContext.createUrl(\.remoteConfigBaseUrl, version: "", withAppCode: false, path: "\(sdkContext.config?.applicationCode ?? "")")

        let remoteConfigRequest = URLRequest.create(url: remoteConfigUrlString)
        let result: (Data, HTTPURLResponse) = try await networkClient.send(request: remoteConfigRequest)
        if result.1.isOk() {
            return result.0
        } else {
            return nil
        }
    }
}
