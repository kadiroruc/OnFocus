import Foundation
import CoreData

@objc(CachedEntity)
final class CachedEntity: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var type: String
    @NSManaged var jsonData: Data
    @NSManaged var updatedAt: Date
    @NSManaged var isDirty: Bool
    @NSManaged var isMarkedDeleted: Bool
}
