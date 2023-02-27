//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

struct DefaultUrls: Decodable, Equatable {
    let loggingUrl: String
    let clientServiceBaseUrl: String
    let eventServiceBaseUrl: String
    let predictBaseUrl: String
    let deepLinkBaseUrl: String
    let inboxBaseUrl: String
    let remoteConfigBaseUrl: String
}

extension DefaultUrls {
    func copyWith(loggingUrl: String? = nil,
                  clientServiceBaseUrl: String? = nil,
                  eventServiceBaseUrl: String? = nil,
                  predictBaseUrl: String? = nil,
                  deepLinkBaseUrl: String? = nil,
                  inboxBaseUrl: String? = nil,
                  remoteConfigBaseUrl: String? = nil) -> DefaultUrls {
        return DefaultUrls(
            loggingUrl: loggingUrl ?? self.loggingUrl,
            clientServiceBaseUrl: clientServiceBaseUrl ?? self.clientServiceBaseUrl,
            eventServiceBaseUrl: eventServiceBaseUrl ?? self.eventServiceBaseUrl,
            predictBaseUrl: predictBaseUrl ?? self.predictBaseUrl,
            deepLinkBaseUrl: deepLinkBaseUrl ?? self.deepLinkBaseUrl,
            inboxBaseUrl: inboxBaseUrl ?? self.inboxBaseUrl,
            remoteConfigBaseUrl: remoteConfigBaseUrl ?? self.remoteConfigBaseUrl
        )
    }
}
