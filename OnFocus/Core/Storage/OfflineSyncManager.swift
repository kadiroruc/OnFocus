import Foundation
import UIKit

final class OfflineSyncManager {
    private let localStore: OfflineStoreProtocol
    private let profileService: ProfileService
    private let friendsService: FriendsService
    private let timerService: TimerService

    private var isSyncing = false

    init(
        localStore: OfflineStoreProtocol,
        profileService: ProfileService,
        friendsService: FriendsService,
        timerService: TimerService
    ) {
        self.localStore = localStore
        self.profileService = profileService
        self.friendsService = friendsService
        self.timerService = timerService
    }

    func start() {
        NetworkMonitor.shared.onStatusChange = { [weak self] online in
            guard online else { return }
            Task { await self?.syncPendingOperations() }
        }
        NetworkMonitor.shared.start()
        Task { await self.syncPendingOperations() }
    }

    @MainActor
    func syncPendingOperations() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        let operations = localStore.pendingOperations()
        for operation in operations {
            do {
                try await perform(operation: operation)
                localStore.removeOperation(id: operation.id)
            } catch {
                localStore.updateOperationFailure(id: operation.id, error: error.localizedDescription)
                break
            }
        }
    }

    private func perform(operation: PendingOperationDTO) async throws {
        switch operation.operation {
        case .profileUpsert:
            guard let data = operation.jsonData else { return }
            let payload = try JSONDecoder().decode(ProfileUpsertPayload.self, from: data)
            let image: UIImage?
            if let base64 = payload.profileImageBase64, let imageData = Data(base64Encoded: base64) {
                image = UIImage(data: imageData)
            } else {
                image = nil
            }
            try await asyncCall { completion in
                self.profileService.saveProfileInternal(
                    name: payload.name,
                    nickname: payload.nickname,
                    image: image,
                    shouldEnqueueOnFailure: false,
                    completion: completion
                )
            }

        case .profileUpdateImage:
            guard let data = operation.jsonData else { return }
            let payload = try JSONDecoder().decode(ProfileImagePayload.self, from: data)
            guard let imageData = Data(base64Encoded: payload.imageBase64), let image = UIImage(data: imageData) else { return }
            try await asyncCall { completion in
                self.profileService.updateProfileImageInternal(image, shouldEnqueueOnFailure: false, completion: completion)
            }

        case .profileUpdateStreak:
            var dayString: String? = nil
            if let data = operation.jsonData,
               let payload = try? JSONDecoder().decode(ProfileStreakPayload.self, from: data) {
                dayString = payload.dayString
            }
            try await asyncCall { completion in
                self.profileService.updateStreakDayInternal(shouldEnqueueOnFailure: false, dayString: dayString, completion: completion)
            }

        case .profileDelete:
            try await asyncCall { completion in
                self.profileService.deleteProfileInternal(shouldEnqueueOnFailure: false, completion: completion)
            }

        case .profileDeleteStatisticsAndFriendships:
            try await asyncCall { completion in
                self.profileService.deleteStatisticsAndFriendshipsInternal(shouldEnqueueOnFailure: false, completion: completion)
            }

        case .friendRequestSend:
            guard let data = operation.jsonData else { return }
            let payload = try JSONDecoder().decode(FriendRequestPayload.self, from: data)
            try await asyncCall { completion in
                self.friendsService.sendFriendRequestInternal(
                    from: payload.senderId,
                    to: payload.receiverId,
                    shouldEnqueueOnFailure: false,
                    completion: completion
                )
            }

        case .friendRequestCancel:
            guard let data = operation.jsonData else { return }
            let payload = try JSONDecoder().decode(FriendRequestPayload.self, from: data)
            try await asyncCall { completion in
                self.friendsService.cancelFriendRequestInternal(
                    from: payload.senderId,
                    to: payload.receiverId,
                    shouldEnqueueOnFailure: false,
                    completion: completion
                )
            }

        case .friendRequestAccept:
            guard let data = operation.jsonData else { return }
            let payload = try JSONDecoder().decode(FriendRequestPayload.self, from: data)
            try await asyncCall { completion in
                self.friendsService.acceptFriendRequestInternal(
                    from: payload.senderId,
                    to: payload.receiverId,
                    shouldEnqueueOnFailure: false,
                    completion: completion
                )
            }

        case .friendRequestReject:
            guard let data = operation.jsonData else { return }
            let payload = try JSONDecoder().decode(FriendRequestPayload.self, from: data)
            try await asyncCall { completion in
                self.friendsService.rejectFriendRequestInternal(
                    from: payload.senderId,
                    to: payload.receiverId,
                    shouldEnqueueOnFailure: false,
                    completion: completion
                )
            }

        case .timerSaveSession:
            guard let data = operation.jsonData else { return }
            let payload = try JSONDecoder().decode(SessionPayload.self, from: data)
            try await timerService.saveSessionAndUpdateAggregatesInternal(
                payload.session,
                userId: payload.userId,
                shouldEnqueueOnFailure: false
            )
        }
    }

    private func asyncCall(_ work: @escaping (@escaping (Result<Void, Error>) -> Void) -> Void) async throws {
        try await withCheckedThrowingContinuation { continuation in
            work { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
