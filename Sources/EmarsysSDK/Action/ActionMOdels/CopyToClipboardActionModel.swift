//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct CopyToClipboardActionModel: ActionModellable {
    let type: String
    
    let text: String
}
