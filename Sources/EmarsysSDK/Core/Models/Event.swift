//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
import CoreData

struct Event {
    let type: String
    let name: String
    let payload: [String: String]?
    let timeStamp: Date
    let config: Config
}

extension Event: Stashable {
    
    func toEntity(mox: NSManagedObjectContext) throws -> EventEntity {
        var entity =  NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: mox) as! EventEntity
        entity.type = type
        entity.name = name
        entity.payload = payload
        entity.timestamp = timeStamp
        entity.config = try config.toEntity(mox: mox)
        return entity
    }
    
    static func fromEntity(entity: EventEntity) throws -> Event {
        return Event(type: entity.type, name: entity.name, payload: entity.payload, timeStamp: entity.timestamp, config: try Config.fromEntity(entity: entity.config))
    }
}
