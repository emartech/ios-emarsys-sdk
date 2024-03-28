//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

struct RequestPushPermissionAction: Action {
    let application: ApplicationApi
    
    func execute() async throws {
        await application.requestPushPermission()
    }
}
