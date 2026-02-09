//
//  NotificationsViewModelInterface.swift
//  Test
//
//  Created by Abdulkadir Oruç on 6.06.2025.
//

import Foundation
import FirebaseFirestore

protocol NotificationsViewModelInterface {
    var notifications: [NotificationModel] { get }
    var view: NotificationsViewInterface? { get set }
    
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func numberOfItems() -> Int
    func notification(at index: Int) -> NotificationModel
    func acceptNotification(at index: Int)
    func declineNotification(at index: Int)
    func didTapProfileImage(at indexPath: IndexPath)
}

final class NotificationsViewModel{
    
    weak var view: NotificationsViewInterface?
    
    private(set) var friendshipModels: [FriendshipModel] = []
    private(set) var notifications: [NotificationModel] = []
    
    private let friendsService: FriendsServiceProtocol
    private let profileService: ProfileServiceProtocol
    private var friendRequestsListener: ListenerRegistration?
    
    init(friendsService: FriendsServiceProtocol, profileService: ProfileServiceProtocol) {
        self.friendsService = friendsService
        self.profileService = profileService
    }
    
    deinit {
        friendRequestsListener?.remove()
    }
    
    private func updateNotifications(with requests: [FriendshipModel]) {
        guard !requests.isEmpty else {
            friendshipModels = []
            notifications = []
            view?.reloadData()
            view?.setNoNotificationsLabel(hidden: false)
            view?.setBadgeCount(0)
            return
        }
        
        friendshipModels = requests
        notifications = []
        
        let group = DispatchGroup()
        
        for friendship in requests {
            group.enter()
            profileService.fetchRequestProfileFor(userId: friendship.user1Id) { [weak self] result in
                defer { group.leave() }
                guard let self = self else { return }
                
                switch result {
                case .success(let profile):
                    let notification = NotificationModel(user: profile, type: friendship.status, date: friendship.createdAt)
                    self.notifications.append(notification)
                case .failure(let error):
                    print("Profile fetch error: \(error.localizedDescription)")
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.view?.setNoNotificationsLabel(hidden: !self.notifications.isEmpty)
            self.view?.setBadgeCount(self.notifications.count)
            self.view?.reloadData()
        }
    }
    
 
}

extension NotificationsViewModel: NotificationsViewModelInterface{
    func didTapProfileImage(at indexPath: IndexPath) {
        guard let userId = notifications[indexPath.item].user.id else {return}
        view?.navigateToProfileDetail(userId: userId)
    }
    
    
    func viewDidLoad() {
        viewWillAppear()
    }
    
    func viewWillAppear() {
        guard let userId = profileService.currentUserId else {
            view?.showMessage(Constants.ValidationMessages.notLoggedIn, type: .error)
            return
        }
        
        if friendRequestsListener != nil {
            return
        }
        
        friendRequestsListener = friendsService.observeFriendRequests(for: userId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let requests):
                    self.updateNotifications(with: requests)
                case .failure(let error):
                    print("Friendship requests fetch error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func viewWillDisappear() {
        // Keep listener alive to update tab bar badge while user is on other tabs.
    }
    
    func numberOfItems() -> Int {
        return notifications.count
    }
    
    func notification(at index: Int) -> NotificationModel {
        return notifications[index]
    }
    
    func acceptNotification(at index: Int) {
        guard index < friendshipModels.count else { return }
        let friendship = friendshipModels[index]
        friendsService.acceptFriendRequest(from: friendship.user1Id, to: friendship.user2Id) { result in
            switch result {
            case .success:
                print("Friend request accepted successfully")
            case .failure(let error):
                print("Friend request acceptance error: \(error.localizedDescription)")
            }
        }
    }

    func declineNotification(at index: Int) {
        guard index < friendshipModels.count else { return }
        let friendship = friendshipModels[index]
        friendsService.rejectFriendRequest(from: friendship.user1Id, to: friendship.user2Id) { result in
            switch result {
            case .success:
                print("Friend request rejected successfully")
            case .failure(let error):
                print("Friend request reject error: \(error.localizedDescription)")
            }
        }
    }
}
