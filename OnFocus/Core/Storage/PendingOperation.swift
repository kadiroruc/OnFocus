import Foundation
import CoreData

@objc(PendingOperation)
final class PendingOperation: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var entityType: String
    @NSManaged var entityId: String
    @NSManaged var operation: String
    @NSManaged var jsonData: Data?
    @NSManaged var createdAt: Date
    @NSManaged var retryCount: Int16
    @NSManaged var lastError: String?
}
