//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct DeeplinkClient {
    
    let networkClient: NetworkClient
    let defaultValues: DefaultValues
    let deviceInfoCollector: DeviceInfoCollector
    
    func sendDeepLinkTrackingId(trackingId: String) async throws {
        guard let url = URL(string: defaultValues.deepLinkBaseUrl) else {
            return //TODO: error handling what to do
        }
        
        let userAgent = "Emarsys SDK \(defaultValues.version) \(deviceInfoCollector.deviceType()) \(deviceInfoCollector.osVersion())"

        var body = ["ems_dl": trackingId]
        let headers = ["User-Agent": userAgent]
        
        let request = URLRequest.create(url: url, method: .POST, headers:headers, body: body.toData())
        
        let result: (Data, HTTPURLResponse) = try await networkClient.send(request: request)
        
        // TODO: result?
    }
    
}
