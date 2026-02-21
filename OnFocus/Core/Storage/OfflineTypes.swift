import Foundation

enum OfflineEntityType: String {
    case profile
    case friendship
    case session
    case statistic
    case appVersion
}

enum OfflineOperationKind: String {
    case profileUpsert
    case profileUpdateImage
    case profileUpdateStreak
    case profileDelete
    case profileDeleteStatisticsAndFriendships
    case friendRequestSend
    case friendRequestCancel
    case friendRequestAccept
    case friendRequestReject
    case timerSaveSession
}

struct PendingOperationDTO {
    let id: String
    let entityType: OfflineEntityType
    let entityId: String
    let operation: OfflineOperationKind
    let jsonData: Data?
    let createdAt: Date
    let retryCount: Int
    let lastError: String?
}

struct ProfileUpsertPayload: Codable {
    let userId: String
    let name: String
    let nickname: String
    let profileImageBase64: String?
}

struct ProfileImagePayload: Codable {
    let userId: String
    let imageBase64: String
}

struct ProfileStreakPayload: Codable {
    let userId: String
    let dayString: String
}

struct FriendRequestPayload: Codable {
    let senderId: String
    let receiverId: String
}

struct SessionPayload: Codable {
    let userId: String
    let session: SessionModel
}

struct AppVersionCache: Codable {
    let minimumVersion: String
    let appStoreURL: String
}
