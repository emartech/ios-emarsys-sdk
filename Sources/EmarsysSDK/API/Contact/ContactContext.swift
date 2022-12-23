//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct ContactContext {
    
    var calls = [ContactCall]()
    
}

enum ContactCall {
    case linkContact(Int, String)
    case linkAuthenticatedContact(Int, String)
    case unlinkContact
}

