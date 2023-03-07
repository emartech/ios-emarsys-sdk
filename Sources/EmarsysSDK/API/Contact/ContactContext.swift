//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
class ContactContext {
    var calls = [ContactCall]()
}

enum ContactCall: Equatable {
    case linkContact(Int, String)
    case linkAuthenticatedContact(Int, String)
    case unlinkContact
}
