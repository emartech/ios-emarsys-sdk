import CoreData
import Foundation

public struct EmarsysConfig: Equatable {
    var applicationCode: String?
    var merchantId: String?
}

extension EmarsysConfig {
    
    func isValid() throws -> Bool {
        let invalidCases = ["nil", "null", "", "0", "test"]
        
        if let applicationCode = applicationCode, invalidCases.contains(applicationCode.lowercased()) {
            throw Errors.preconditionFailed(message: "ApplicationCode should be valid.")
        }
        if let merchantId = applicationCode, invalidCases.contains(merchantId.lowercased()) {
            throw Errors.preconditionFailed(message: "MerchantId should be valid.")
        }
        if applicationCode == nil && merchantId == nil {
            throw Errors.preconditionFailed(message: "ApplicationCode or MerchantId must be present for Tracking")
        }
        return true
    }
}

extension EmarsysConfig: Stashable {
    
    func toEntity(mox: NSManagedObjectContext) throws -> ConfigEntity {
        let entity =
        NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: mox)
        as! ConfigEntity
        entity.applicationCode = applicationCode
        entity.merchantId = merchantId
        return entity
    }
    
    static func fromEntity(entity: ConfigEntity) throws -> EmarsysConfig {
        EmarsysConfig(applicationCode: entity.applicationCode, merchantId: entity.merchantId)
    }
    
}
