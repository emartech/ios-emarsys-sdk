//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//


import Foundation


class MobileEngageSession: SessionApi {
    let sessionContext: SessionContext
    let sdkContext: SdkContext
    let timestampProvider: any DateProvider
    let uuidProvider: any StringProvider
    let eventClient: any EventClient
    let logger: SdkLogger
    
    var sessionStartTime: Date? = nil
    
    init(sessionContext: SessionContext,
         sdkContext: SdkContext,
         timestampProvider: any DateProvider,
         uuidProvider: any StringProvider,
         eventClient: any EventClient,
         logger: SdkLogger
    ) {
        self.sessionContext = sessionContext
        self.sdkContext = sdkContext
        self.timestampProvider = timestampProvider
        self.uuidProvider = uuidProvider
        self.eventClient = eventClient
        self.logger = logger
    }
    
    func start() async {
        if ((self.sdkContext.config?.applicationCode != nil) && (self.sessionContext.contactToken != nil)) {
            self.sessionStartTime = self.timestampProvider.provide()
            self.sessionContext.sessionId = self.uuidProvider.provide()
            do {
                _ = try await eventClient.sendEvents(name: Constants.Session.sessionStart, attributes: nil, eventType: EventType.internalEvent)
            } catch {
                self.sessionStartTime = nil
                self.sessionContext.sessionId = nil
                logger.log(logEntry: LogEntry(topic: "mobile-engage-session", data: ["error": error.localizedDescription]), level: .error)
            }
        }
    }
    
    func stop() async {
    
    }
    
    
}
