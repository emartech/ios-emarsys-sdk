//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation
import Combine

typealias ContactInstance = ActivationAware & ContactApi

@SdkActor
class Contact<LoggingInstance: ContactInstance, GathererInstance: ContactInstance, InternalInstance: ContactInstance>: GenericApi<LoggingInstance, GathererInstance, InternalInstance>, ContactApi {
    let predictContactInternal: ContactInstance
    
    init(loggingInstance: LoggingInstance,
         gathererInstance: GathererInstance,
         internalInstance: InternalInstance,
         predictContactInternal: ContactInstance,
         sdkContext: SdkContext) {
        self.predictContactInternal = predictContactInternal
        super.init(loggingInstance: loggingInstance, gathererInstance: gathererInstance, internalInstance: internalInstance, sdkContext: sdkContext)
    }
    
    func linkContact(contactFieldId: Int, contactFieldValue: String) async throws {
        guard let active = self.active as? ContactApi else {
            throw Errors.preconditionFailed(message: "Active instance must be ContactApi")
        }
        try await active.linkContact(contactFieldId: contactFieldId, contactFieldValue: contactFieldValue)
    }
    
    func linkAuthenticatedContact(contactFieldId: Int, openIdToken: String) async throws {
        guard let active = self.active as? ContactApi else {
            throw Errors.preconditionFailed(message: "Active instance must be ContactApi")
        }
        try await active.linkAuthenticatedContact(contactFieldId: contactFieldId, openIdToken: openIdToken)
    }
    
    func unlinkContact() async throws {
        guard let active = self.active as? ContactApi else {
            throw Errors.preconditionFailed(message: "Active instance must be ContactApi")
        }
        try await active.unlinkContact()
    }
    
    override func internalInstance(features: [Feature]) -> ActivationAware {
        var instance: ActivationAware = loggingInstance
        if features.contains(Feature.mobileEngage) {
            instance = internalInstance
        } else if features.contains(Feature.predict) {
            instance = predictContactInternal
        }
        return instance
    }
}
