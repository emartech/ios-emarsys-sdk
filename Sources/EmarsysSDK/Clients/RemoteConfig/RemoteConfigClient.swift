import Foundation

@SdkActor
protocol RemoteConfigClient {
    func fetchRemoteConfig() async throws -> RemoteConfigResponse?
}
