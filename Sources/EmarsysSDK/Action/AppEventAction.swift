//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

struct AppEventAction: Action {
    let appEventHandler: EventHandler
    let name: String
    let payload: [String:String]?
    
    
    func execute() async throws {
        appEventHandler(name, payload)
    }
}
