//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct OpenExternalURLActionModel: ActionModellable {
    let type: String
    
    let url: URL //TODO: check what we get when serializing this model and the url is not an URL type
}
