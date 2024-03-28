//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

struct OpenExternalURLAction: Action {
    let actionModel: OpenExternalURLActionModel
    let application: ApplicationApi
    
    @MainActor func execute() async throws {
        application.openUrl(actionModel.url)
    }
}
