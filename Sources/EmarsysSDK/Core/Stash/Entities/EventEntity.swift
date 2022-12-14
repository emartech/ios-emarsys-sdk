//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
import CoreData

class EventEntity: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var payload: [String: String]?
    @NSManaged var timestamp: Date
    @NSManaged var config: ConfigEntity
    
}
