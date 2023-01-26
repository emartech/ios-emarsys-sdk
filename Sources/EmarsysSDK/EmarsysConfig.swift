import Foundation
import CoreData

public struct EmarsysConfig: Equatable {
    var applicationCode:String? = nil
    var merchantId:String? = nil
    var enabledLogLevels: [LogLevel] = []
}

extension EmarsysConfig: Stashable {

    func toEntity(mox: NSManagedObjectContext) throws -> ConfigEntity {
        let entity =  NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: mox) as! ConfigEntity
        entity.applicationCode = applicationCode
        entity.merchantId = merchantId
        return entity
    }
    
    static func fromEntity(entity: ConfigEntity) throws -> EmarsysConfig {
        EmarsysConfig(applicationCode: entity.applicationCode, merchantId: entity.merchantId)
    }

}