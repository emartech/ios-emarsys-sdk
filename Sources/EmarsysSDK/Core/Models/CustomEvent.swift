//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation
import CoreData

struct CustomEvent: Codable {
    let type: String
    let name: String
    let attributes: [String: String]?
    let timestamp: String
}

extension CustomEvent: Stashable {

    func toEntity(mox: NSManagedObjectContext) throws -> EventEntity {
        let entity: EventEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: mox) as! EventEntity
        entity.type = type
        entity.name = name
        entity.payload = attributes
//        entity.timestamp = timestamp
        return entity
    }

    static func fromEntity(entity: EventEntity) throws -> CustomEvent {
        CustomEvent(type: entity.type, name: entity.name, attributes: entity.payload, timestamp: entity.timestamp.toUTC())
    }
}

enum EventType: String {
    case internalEvent = "internal"
    case customEvent = "custom"
}
