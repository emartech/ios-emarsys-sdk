//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation

@propertyWrapper struct StoredValue<Value> {
    let key: String
    var storage: UserDefaults = .standard
    
    var wrappedValue: Value? {
        get { storage.value(forKey: key) as? Value }
        set { storage.setValue(newValue, forKey: key) }
    }
}
