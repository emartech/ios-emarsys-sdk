//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
import CoreData

class ConfigEntity: NSManagedObject {
    @NSManaged var applicationCode: String?
    @NSManaged var merchantId:String?
}
