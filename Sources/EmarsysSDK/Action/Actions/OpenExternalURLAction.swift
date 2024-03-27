//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
import UIKit

struct OpenExternalURLAction: Action {
    let actionModel: OpenExternalURLActionModel
    let application: UIApplication
    
    @MainActor func execute() async throws {
        if application.canOpenURL(actionModel.url) {
            await application.open(actionModel.url)
        }
    }
}
