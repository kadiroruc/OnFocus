//
//  NotificationsViewModelInterface.swift
//  Test
//
//  Created by Abdulkadir Oruç on 6.06.2025.
//

import Foundation

protocol NotificationsViewModelInterface {
    var notifications: [NotificationModel] { get }
    var view: NotificationsViewInterface? { get set }
    
    func viewDidLoad()
    func numberOfItems() -> Int
    func notification(at index: Int) -> NotificationModel
    func acceptNotification(at index: Int)
    func declineNotification(at index: Int)
}

final class NotificationsViewModel: NotificationsViewModelInterface {
    
    weak var view: NotificationsViewInterface?
    
    private(set) var friendshipModels: [FriendshipModel] = []
    private(set) var notifications: [NotificationModel] = []
    
    private let friendsService: FriendsServiceProtocol
    private let profileService: ProfileServiceProtocol
    
    init(friendsService: FriendsServiceProtocol, profileService: ProfileServiceProtocol) {
        self.friendsService = friendsService
        self.profileService = profileService
    }
    
    func viewDidLoad() {
        guard let userId = profileService.currentUserId else {
            view?.showMessage(Constants.ValidationMessages.notLoggedIn, type: .error)
            return
        }

        friendsService.fetchFriendRequests(for: userId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let requests):
                guard !requests.isEmpty else {
                    self.friendshipModels = []
                    self.notifications = []
                    self.view?.reloadData()
                    return
                }

                self.friendshipModels = requests
                self.notifications = []

                let group = DispatchGroup()

                for friendship in requests {
                    group.enter()
                    self.profileService.fetchRequestProfileFor(userId: friendship.user1Id) { result in
                        defer { group.leave() }
                        switch result {
                        case .success(let profile):
                            
                            let notification = NotificationModel(user: profile, type: friendship.status, date: friendship.createdAt)
                            self.notifications.append(notification)
                        case .failure(let error):
                            print("Profile fetch error: \(error.localizedDescription)")
                        }
                    }
                }

                group.notify(queue: .main) {
                    self.view?.reloadData()
                }

            case .failure(let error):
                print("Friendship requests fetch error: \(error.localizedDescription)")
            }
        }
    }
    
    func numberOfItems() -> Int {
        return notifications.count
    }
    
    func notification(at index: Int) -> NotificationModel {
        return notifications[index]
    }
    
    func acceptNotification(at index: Int) {
        let friendship = friendshipModels[index]
        friendsService.acceptFriendRequest(from: friendship.user1Id, to: friendship.user2Id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                print("Friend request accepted successfully")
                self.friendshipModels.remove(at: index)
                self.notifications.remove(at: index)
                self.view?.reloadData()
            case .failure(let error):
                print("Friend request acceptance error: \(error.localizedDescription)")
            }
        }
    }

    func declineNotification(at index: Int) {
        let friendship = friendshipModels[index]
        friendsService.rejectFriendRequest(from: friendship.user1Id, to: friendship.user2Id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                print("Friend request rejected successfully")
                self.friendshipModels.remove(at: index)
                self.notifications.remove(at: index)
                self.view?.reloadData()
            case .failure(let error):
                print("Friend request reject error: \(error.localizedDescription)")
            }
        }
    }
}
