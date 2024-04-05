//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

typealias ConfigInstance = ActivationAware & ConfigInternalApi

class Config<LoggingInstance: ConfigInstance, GathererInstance: ConfigInstance, InternalInstance: ConfigInstance>: GenericApi<LoggingInstance, GathererInstance, InternalInstance>, ConfigApi {
    
    var contactFieldId: Int? {
        self.sdkContext.contactFieldId
    }
    var applicationCode: String? {
        self.sdkContext.config?.applicationCode
    }
    var merchantId: String? {
        self.sdkContext.config?.merchantId
    }
    var hardwareId: String {
        self.deviceInfoCollector.hardwareId()
    }
    var languageCode: String {
        self.deviceInfoCollector.languageCode()
    }
    var sdkVersion: String {
        self.sdkContext.sdkConfig.version
    }
    private let deviceInfoCollector: DeviceInfoCollector
    
    init(loggingInstance: LoggingInstance, gathererInstance: GathererInstance, internalInstance: InternalInstance, sdkContext: SdkContext, deviceInfoCollector: DeviceInfoCollector) {
        self.deviceInfoCollector = deviceInfoCollector
        super.init(loggingInstance: loggingInstance, gathererInstance: gathererInstance, internalInstance: internalInstance, sdkContext: sdkContext)
    }
    
    func pushSettings() async -> PushSettings {
        await self.deviceInfoCollector.pushSettings()
    }
    
    func changeApplicationCode(applicationCode: String) async throws {
        try Constants.InvalidCases.configValue.shouldNotContain(value: applicationCode)
        
        guard let active = self.active as? ConfigInternalApi else {
            throw Errors.preconditionFailed(message: "Active instance must be ConfigInternalApi")
        }
        try await active.changeApplicationCode(applicationCode: applicationCode)
    }
    
    func changeMerchantId(merchantId: String) async throws {
        try Constants.InvalidCases.configValue.shouldNotContain(value: merchantId)
        
        guard let active = self.active as? ConfigInternalApi else {
            throw Errors.preconditionFailed(message: "Active instance must be ConfigInternalApi")
        }
        try await active.changeMerchantId(merchantId: merchantId)
    }
}
