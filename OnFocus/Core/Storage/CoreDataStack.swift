import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    private init() {
        let model = CoreDataStack.makeManagedObjectModel()
        persistentContainer = NSPersistentContainer(name: "OnFocusData", managedObjectModel: model)
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load Core Data store: \(error)")
            }
        }
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    private static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let cachedEntity = NSEntityDescription()
        cachedEntity.name = "CachedEntity"
        cachedEntity.managedObjectClassName = "CachedEntity"
        cachedEntity.properties = [
            CoreDataStack.attribute(name: "id", type: .stringAttributeType, optional: false),
            CoreDataStack.attribute(name: "type", type: .stringAttributeType, optional: false),
            CoreDataStack.attribute(name: "jsonData", type: .binaryDataAttributeType, optional: false, allowsExternalStorage: true),
            CoreDataStack.attribute(name: "updatedAt", type: .dateAttributeType, optional: false),
            CoreDataStack.attribute(name: "isDirty", type: .booleanAttributeType, optional: false, defaultValue: false),
            CoreDataStack.attribute(name: "isMarkedDeleted", type: .booleanAttributeType, optional: false, defaultValue: false)
        ]

        let pendingOperation = NSEntityDescription()
        pendingOperation.name = "PendingOperation"
        pendingOperation.managedObjectClassName = "PendingOperation"
        pendingOperation.properties = [
            CoreDataStack.attribute(name: "id", type: .stringAttributeType, optional: false),
            CoreDataStack.attribute(name: "entityType", type: .stringAttributeType, optional: false),
            CoreDataStack.attribute(name: "entityId", type: .stringAttributeType, optional: false),
            CoreDataStack.attribute(name: "operation", type: .stringAttributeType, optional: false),
            CoreDataStack.attribute(name: "jsonData", type: .binaryDataAttributeType, optional: true, allowsExternalStorage: true),
            CoreDataStack.attribute(name: "createdAt", type: .dateAttributeType, optional: false),
            CoreDataStack.attribute(name: "retryCount", type: .integer16AttributeType, optional: false, defaultValue: 0),
            CoreDataStack.attribute(name: "lastError", type: .stringAttributeType, optional: true)
        ]

        model.entities = [cachedEntity, pendingOperation]
        return model
    }

    private static func attribute(
        name: String,
        type: NSAttributeType,
        optional: Bool,
        allowsExternalStorage: Bool = false,
        defaultValue: Any? = nil
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        attribute.allowsExternalBinaryDataStorage = allowsExternalStorage
        attribute.defaultValue = defaultValue
        return attribute
    }
}
