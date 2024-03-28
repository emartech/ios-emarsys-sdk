//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
class SdkContext {
    
    @Published
    var sdkState: SdkState = .inactive
    
    @Published
    var features: [Feature] = [Feature]()
    
    var inAppDnd: Bool = false
    
    var config: EmarsysConfig? = nil // TODO: figure out smth better
    
    var defaultUrls: DefaultUrls
    
    var sdkConfig: SdkConfig
    
    init(sdkConfig: SdkConfig, defaultUrls: DefaultUrls) {
        self.sdkConfig = sdkConfig
        self.defaultUrls = defaultUrls
    }
        
    func setConfig(config: EmarsysConfig) {
        self.config = config
    }
    
    func setSdkState(sdkState: SdkState) {
        self.sdkState = sdkState
    }
    
    func setFeatures(features: [Feature]) {
        self.features = features
    }
}

extension SdkContext {
    
    func createUrl(_ keyPath: KeyPath<DefaultUrls, String>, version: String = "v3", withAppCode: Bool = true, path: String? = nil) throws -> URL {
        var url: String = defaultUrls[keyPath: keyPath]
        url.append("/\(version)")
        if withAppCode {
            guard let config = config else {
                throw Errors.preconditionFailed(message: "Config must not be nil")
            }
            guard let applicationCode = config.applicationCode else {
                throw Errors.preconditionFailed(message: "Application code must not be nil")
            }
            url.append("/apps/\(applicationCode)")
        }
        if let pathComponent = path {
            url.append(pathComponent)
        }
        if #available(iOS 17.0, macOS 14.0, *) {
            guard let result = URL(string: url, encodingInvalidCharacters: false) else {
                throw Errors.NetworkingError.urlCreationFailed(url: url)
            }
            return result
        } else {
            guard let result = URL(string: url) else {
                throw Errors.NetworkingError.urlCreationFailed(url: url)
            }
            return result
        }
    }
    
}
