//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

class CopyToClipboardAction: Action {
    let actionModel: CopyToClipboardActionModel
    var application: ApplicationApi
 
    init(actionModel: CopyToClipboardActionModel, application: ApplicationApi) {
        self.actionModel = actionModel
        self.application = application
    }
    
    func execute() async throws {
        application.pasteboard = actionModel.text
    }
}
