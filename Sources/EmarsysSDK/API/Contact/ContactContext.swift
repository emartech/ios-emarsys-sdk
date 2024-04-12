//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
class ContactContext {
    var calls: any RangeReplaceableCollection<ContactCall>
    
    init(calls: any RangeReplaceableCollection<ContactCall>) {
        self.calls = calls
    }
}

enum ContactCall: Codable, Equatable {
    case linkContact(Int, String)
    case linkAuthenticatedContact(Int, String)
    case unlinkContact
}
