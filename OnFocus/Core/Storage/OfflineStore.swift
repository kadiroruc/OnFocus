import Foundation
import CoreData

protocol OfflineStoreProtocol {
    func save<T: Codable>(entity: T, id: String, type: OfflineEntityType, markDirty: Bool)
    func saveAll<T: Codable>(entities: [T], type: OfflineEntityType, idProvider: (T) -> String, markDirty: Bool)
    func fetch<T: Codable>(id: String, type: OfflineEntityType) -> T?
    func fetchAll<T: Codable>(type: OfflineEntityType) -> [T]
    func markDeleted(id: String, type: OfflineEntityType)
    func markClean(id: String, type: OfflineEntityType)

    func enqueue(operation: OfflineOperationKind, entityType: OfflineEntityType, entityId: String, payload: Data?)
    func pendingOperations() -> [PendingOperationDTO]
    func removeOperation(id: String)
    func updateOperationFailure(id: String, error: String)
}

final class OfflineStore: OfflineStoreProtocol {
    private let stack: CoreDataStack
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func save<T: Codable>(entity: T, id: String, type: OfflineEntityType, markDirty: Bool) {
        let context = stack.newBackgroundContext()
        context.performAndWait {
            let cached = fetchOrCreateCachedEntity(id: id, type: type, in: context)
            do {
                cached.jsonData = try encoder.encode(entity)
                cached.updatedAt = Date()
                cached.isDirty = markDirty
                cached.isMarkedDeleted = false
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }

    func saveAll<T: Codable>(entities: [T], type: OfflineEntityType, idProvider: (T) -> String, markDirty: Bool) {
        let context = stack.newBackgroundContext()
        context.performAndWait {
            do {
                for entity in entities {
                    let id = idProvider(entity)
                    let cached = fetchOrCreateCachedEntity(id: id, type: type, in: context)
                    cached.jsonData = try encoder.encode(entity)
                    cached.updatedAt = Date()
                    cached.isDirty = markDirty
                    cached.isMarkedDeleted = false
                }
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }

    func fetch<T: Codable>(id: String, type: OfflineEntityType) -> T? {
        let context = stack.persistentContainer.viewContext
        let request = NSFetchRequest<CachedEntity>(entityName: "CachedEntity")
        request.predicate = NSPredicate(format: "id == %@ AND type == %@ AND isMarkedDeleted == NO", id, type.rawValue)
        request.fetchLimit = 1
        guard let cached = try? context.fetch(request).first else { return nil }
        return try? decoder.decode(T.self, from: cached.jsonData)
    }

    func fetchAll<T: Codable>(type: OfflineEntityType) -> [T] {
        let context = stack.persistentContainer.viewContext
        let request = NSFetchRequest<CachedEntity>(entityName: "CachedEntity")
        request.predicate = NSPredicate(format: "type == %@ AND isMarkedDeleted == NO", type.rawValue)
        let results = (try? context.fetch(request)) ?? []
        return results.compactMap { try? decoder.decode(T.self, from: $0.jsonData) }
    }

    func markDeleted(id: String, type: OfflineEntityType) {
        let context = stack.newBackgroundContext()
        context.performAndWait {
            let cached = fetchOrCreateCachedEntity(id: id, type: type, in: context)
            cached.isMarkedDeleted = true
            cached.isDirty = true
            cached.updatedAt = Date()
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }

    func markClean(id: String, type: OfflineEntityType) {
        let context = stack.newBackgroundContext()
        context.performAndWait {
            guard let cached = fetchCachedEntity(id: id, type: type, in: context) else { return }
            cached.isDirty = false
            cached.updatedAt = Date()
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }

    func enqueue(operation: OfflineOperationKind, entityType: OfflineEntityType, entityId: String, payload: Data?) {
        let context = stack.newBackgroundContext()
        context.performAndWait {
            let op = PendingOperation(context: context)
            op.id = UUID().uuidString
            op.entityType = entityType.rawValue
            op.entityId = entityId
            op.operation = operation.rawValue
            op.jsonData = payload
            op.createdAt = Date()
            op.retryCount = 0
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }

    func pendingOperations() -> [PendingOperationDTO] {
        let context = stack.persistentContainer.viewContext
        let request = NSFetchRequest<PendingOperation>(entityName: "PendingOperation")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        let results = (try? context.fetch(request)) ?? []
        return results.compactMap { op in
            guard let entityType = OfflineEntityType(rawValue: op.entityType),
                  let operation = OfflineOperationKind(rawValue: op.operation) else { return nil }
            return PendingOperationDTO(
                id: op.id,
                entityType: entityType,
                entityId: op.entityId,
                operation: operation,
                jsonData: op.jsonData,
                createdAt: op.createdAt,
                retryCount: Int(op.retryCount),
                lastError: op.lastError
            )
        }
    }

    func removeOperation(id: String) {
        let context = stack.newBackgroundContext()
        context.performAndWait {
            let request = NSFetchRequest<PendingOperation>(entityName: "PendingOperation")
            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1
            if let op = try? context.fetch(request).first {
                context.delete(op)
                do {
                    try context.save()
                } catch {
                    context.rollback()
                }
            }
        }
    }

    func updateOperationFailure(id: String, error: String) {
        let context = stack.newBackgroundContext()
        context.performAndWait {
            let request = NSFetchRequest<PendingOperation>(entityName: "PendingOperation")
            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1
            if let op = try? context.fetch(request).first {
                op.retryCount += 1
                op.lastError = error
                do {
                    try context.save()
                } catch {
                    context.rollback()
                }
            }
        }
    }

    private func fetchCachedEntity(id: String, type: OfflineEntityType, in context: NSManagedObjectContext) -> CachedEntity? {
        let request = NSFetchRequest<CachedEntity>(entityName: "CachedEntity")
        request.predicate = NSPredicate(format: "id == %@ AND type == %@", id, type.rawValue)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func fetchOrCreateCachedEntity(id: String, type: OfflineEntityType, in context: NSManagedObjectContext) -> CachedEntity {
        if let existing = fetchCachedEntity(id: id, type: type, in: context) {
            return existing
        }
        let entity = CachedEntity(context: context)
        entity.id = id
        entity.type = type.rawValue
        entity.updatedAt = Date()
        entity.isDirty = false
        entity.isMarkedDeleted = false
        return entity
    }
}
