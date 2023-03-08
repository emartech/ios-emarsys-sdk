//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
class DefaultRemoteConfigHandler: RemoteConfigHandler {
    private let deviceInfoCollector: DeviceInfoCollector
    private let remoteConfigClient: RemoteConfigClient
    private let sdkContext: SdkContext
    private let sdkLogger: SdkLogger
    private let randomProvider: any DoubleProvider

    init(deviceInfoCollector: DeviceInfoCollector, remoteConfigClient: RemoteConfigClient, sdkContext: SdkContext, sdkLogger: SdkLogger, randomProvider: any DoubleProvider) {
        self.deviceInfoCollector = deviceInfoCollector
        self.remoteConfigClient = remoteConfigClient
        self.sdkContext = sdkContext
        self.sdkLogger = sdkLogger
        self.randomProvider = randomProvider
    }

    func handle() async throws {
        guard let config = try await remoteConfigClient.fetchRemoteConfig() else {
            return
        }

        let hardwareId = await deviceInfoCollector.collect().hardwareId

        applyServiceUrls(serviceUrls: config.serviceUrls)
        applyLogLevel(logLevel: config.logLevel)
        applyFeatures(features: config.features)
        applyLuckyLogger(luckyLogger: config.luckyLogger)

        guard let hardwareIdOverrides = config.overrides else {
            return
        }

        if let override = hardwareIdOverrides[hardwareId] {
            applyServiceUrls(serviceUrls: override.serviceUrls)
            applyFeatures(features: override.features)
            applyLogLevel(logLevel: override.logLevel)
        }
    }

    private func applyFeatures(features: RemoteConfigFeatures?) {
        if let override = features {
            if let mobileEngageFeature = override.mobileEngage {
                if mobileEngageFeature {
                    if !sdkContext.features.contains(.mobileEngage) {
                        sdkContext.features.append(.mobileEngage)
                    }
                } else {
                    if sdkContext.features.contains(.mobileEngage) {
                        sdkContext.features.removeAll { feature in
                            feature == .mobileEngage
                        }
                    }
                }
            }
            if let predictFeature = override.predict {
                if predictFeature {
                    if !sdkContext.features.contains(.predict) {
                        sdkContext.features.append(.predict)
                    }
                } else {
                    if sdkContext.features.contains(.predict) {
                        sdkContext.features.removeAll { feature in
                            feature == .predict
                        }
                    }
                }
            }
        }
    }

    private func applyServiceUrls(serviceUrls: ServiceUrls?) {
        if let override = serviceUrls {
            sdkContext.defaultUrls = sdkContext.defaultUrls.copyWith(
                    clientServiceBaseUrl: override.clientService,
                    eventServiceBaseUrl: override.eventService,
                    predictBaseUrl: override.predictService,
                    deepLinkBaseUrl: override.deepLinkService,
                    inboxBaseUrl: override.inboxService)
        }
    }

    private func applyLogLevel(logLevel: String?) {
        if let override = logLevel {
            sdkContext.sdkConfig.remoteLogLevel = override
        }
    }

    private func applyLuckyLogger(luckyLogger: LuckyLogger?) {
        if let override = luckyLogger {
            let randomNumber = randomProvider.provide()
            if override.threshold != 0 && randomNumber <= override.threshold {
                sdkContext.sdkConfig.remoteLogLevel = override.logLevel
            }
        }
    }
}
