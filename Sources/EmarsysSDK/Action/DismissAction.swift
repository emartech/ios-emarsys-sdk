//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

struct DismissAction: Action {
    let dismissHandler: DismissHandler
    
    func execute() async throws {
        dismissHandler()
    }
}
