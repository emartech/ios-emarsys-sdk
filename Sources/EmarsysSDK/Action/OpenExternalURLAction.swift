//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
import UIKit

struct OpenExternalURLAction: Action {
    let url: URL
    let application: UIApplication
    
    @MainActor func execute() async throws {
        if application.canOpenURL(url) {
            await application.open(url)
        }
    }
}
