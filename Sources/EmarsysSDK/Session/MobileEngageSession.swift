//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//


import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(Cocoa)
import Cocoa
#endif

@SdkActor
class MobileEngageSession: SessionApi {
    let application: any ApplicationApi
    let sessionContext: SessionContext
    let sdkContext: SdkContext
    let timestampProvider: any DateProvider
    let uuidProvider: any StringProvider
    let eventClient: any EventClient
    let logger: SdkLogger
    
    var sessionStartTime: Date? = nil
    
    init(application: any ApplicationApi,
         sessionContext: SessionContext,
         sdkContext: SdkContext,
         timestampProvider: any DateProvider,
         uuidProvider: any StringProvider,
         eventClient: any EventClient,
         logger: SdkLogger
    ) {
        self.application = application
        self.sessionContext = sessionContext
        self.sdkContext = sdkContext
        self.timestampProvider = timestampProvider
        self.uuidProvider = uuidProvider
        self.eventClient = eventClient
        self.logger = logger
    }
    
    func start() async {
        if (self.canStartSession()) {
            self.sessionStartTime = self.timestampProvider.provide()
            self.sessionContext.sessionId = self.uuidProvider.provide()
            do {
                _ = try await eventClient.sendEvents(name: Constants.Session.sessionStart, attributes: nil, eventType: EventType.internalEvent)
            } catch {
                resetSession()
                logger.log(logEntry: LogEntry(topic: "mobile-engage-session-start", data: ["error": error.localizedDescription]), level: .error)
            }
        }
    }
    
    func stop() async {
        let endTime = timestampProvider.provide()
        guard let sessionStartTime, let _ = self.sessionContext.sessionId else {
            logger.log(logEntry: LogEntry(topic: "mobile-engage-session-stop", data: ["message": "Session must be started before calling stop!"]), level: .error)
            return
        }
        
        let attributes = ["duration":"\(endTime.timeElapsedInMillis(fromDate: sessionStartTime))"]
        do {
            defer {
                resetSession()
            }
            _ = try await eventClient.sendEvents(name: Constants.Session.sessionStop, attributes: attributes, eventType: EventType.internalEvent)
        } catch {
            logger.log(logEntry: LogEntry(topic: "mobile-engage-session-stop", data: ["error": error.localizedDescription]), level: .error)
        }
    }
    
    private func resetSession() {
        self.sessionStartTime = nil
        self.sessionContext.sessionId = nil
    }
    
    func registerForApplifecycleChanges() async {
        await self.application.registerForAppLifecycle(lifecycle: .didBecomeActive) {
            await self.start()
        }     
        await self.application.registerForAppLifecycle(lifecycle: .didEnterBackground) {
            await self.stop()
        }
    }
    
    private func canStartSession() -> Bool {
        self.sdkContext.config?.applicationCode != nil &&
        self.sessionContext.contactToken != nil &&
        self.sessionContext.sessionId == nil &&
        self.sessionStartTime == nil
    }
}
