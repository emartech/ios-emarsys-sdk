//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

@SdkActor
protocol EventApi {
    
    func trackCustomEvent(name: String, attributes: [String: String]?) async throws
    
}
