//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

@SdkActor
struct AppEventActionModel: ActionModellable {
    let type: String
    
    let name: String
    let payload: [String: String]?
}
