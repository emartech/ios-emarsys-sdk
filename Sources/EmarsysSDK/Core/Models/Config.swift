//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
import CoreData

struct Config {
    let applicationCode: String
}


extension Config: Stashable {
    
    func toEntity(mox: NSManagedObjectContext) throws -> ConfigEntity {
        var entity =  NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: mox) as! ConfigEntity
        entity.applicationCode = applicationCode
        return entity
    }
    
    static func fromEntity(entity: ConfigEntity) throws -> Config {
        return Config(applicationCode: entity.applicationCode)
    }

}
