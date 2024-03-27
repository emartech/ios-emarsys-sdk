//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
import UIKit

struct CopyToClipboardAction: Action {
    let actionModel: CopyToClipboardActionModel
    let uiPasteBoard: UIPasteboard
    
    func execute() async throws {
        uiPasteBoard.string = actionModel.text
    }
}
