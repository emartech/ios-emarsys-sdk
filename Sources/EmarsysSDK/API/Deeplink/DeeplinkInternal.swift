//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

struct DeeplinkInternal: DeeplinkApi {
    
    let deeplinkClient: DeeplinkClient
    
    func trackDeeplink(userActivity: NSUserActivity) async throws -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            return false
        }
        guard let url = userActivity.webpageURL else {
            return false
        }
        guard let trackingId = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: { $0.name == "ems_dl"
        })?.value else {
            return false
        }
        try? await deeplinkClient.sendDeepLinkTrackingId(trackingId: trackingId)
        return true
    }
    
}
