//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct RegisterClientState: State {
    
    var context: StateContext?
    
    let networkClient: NetworkClient
    let deviceInfoCollector: DeviceInfoCollector
    let defaultValues: DefaultValues
    let config: Config
    
    var name = SetupState.registerClient.rawValue
    
    func prepare() {
    }
    
    func activate() async {
        guard let clientRegistrationUrl = URL(string: defaultValues.clientServiceBaseUrl.appending("/v3/apps/\(config.applicationCode)/client")) else {
            return //TODO: error handling what to do
        }
        let request = URLRequest.create(url: clientRegistrationUrl, method: .POST, )
        
        
        
        let deviceInfo = await deviceInfoCollector.collectInfo()
    }
    
    func relax() {
    }
    
}
