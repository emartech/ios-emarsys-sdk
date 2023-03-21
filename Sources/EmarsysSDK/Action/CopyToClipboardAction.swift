//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
import UIKit

struct CopyToClipboardAction: Action {
    let uiPasteBoard: UIPasteboard
    let text: String
    
    func execute() async throws {
        uiPasteBoard.string = text
    }
}
