//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//

import CoreData
import Foundation

@SdkActor
protocol Stash {
    
    var mox: NSManagedObjectContext { get }
    
}

struct DefaultStash: Stash {
    
    var mox: NSManagedObjectContext
    
    init() async throws {
        guard let modelURL = Bundle.module.url(forResource: "Model", withExtension:"momd") else {
            throw Errors.resourceLoadingFailed(resource: "ModelUrl")
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            throw Errors.resourceLoadingFailed(resource: "model")
        }
        guard let dbUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("EmarsysSdk.sqlite") else {
            throw Errors.resourceLoadingFailed(resource: "EmarsysSdk.sqlite")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        mox = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        mox.persistentStoreCoordinator = psc
        _ = try psc.addPersistentStore(type: .sqlite, at: dbUrl)
    }
    
}

@SdkActor
class Dao<T> where T: Stashable {
    
    let stash: Stash
    
    init(stash: Stash) {
        self.stash = stash
    }
    
    func save(item: T) async throws {
        do {
            _ = try item.toEntity(mox: self.stash.mox)
            try stash.mox.save()
        } catch {
            throw
            Errors.StorageError.savingItemFailed(item: String(describing: item), error:  error.localizedDescription)
        }
    }
    
    func save(items: [T]) async throws {
        do {
            _ = try items.map { stashable in
                try stashable.toEntity(mox: self.stash.mox)
            }
            try stash.mox.save()
        } catch {
            throw Errors.StorageError.savingItemFailed(item: String(describing: items), error:  error.localizedDescription)
        }
    }
    
    func find(predicate: NSPredicate) async throws -> [T] {
        let request = createFetchRequest()
        request.predicate = predicate
        return try await self.stash.mox.perform {
            try self.stash.mox.fetch(request).compactMap { try T.fromEntity(entity: $0) }
        }
    }
    
    func createFetchRequest() -> NSFetchRequest<T.Entity> {
        return NSFetchRequest<T.Entity>(entityName: String(describing: T.self))
    }
    
}

protocol Stashable {
    associatedtype Entity: NSManagedObject
    
    static func fromEntity(entity: Entity) throws -> Self
    
    func toEntity(mox: NSManagedObjectContext) throws -> Entity
}
