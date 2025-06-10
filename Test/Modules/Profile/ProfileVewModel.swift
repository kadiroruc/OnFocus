//
//  ProfileVewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 17.05.2025.
//

import UIKit
import FirebaseAuth

// MARK: - ProfileViewModelInterface

protocol ProfileViewModelInterface: AnyObject {
    var view: ProfileViewInterface? { get set }
    
    func viewDidLoad()
    func isDatePartOfStreak(_ date: Date) -> Bool
    func isDateConnectedLeft(_ date: Date) -> Bool
    func isDateConnectedRight(_ date: Date) -> Bool
    func signOut()
    func addFriendTapped()
}

// MARK: - ProfileViewModel

final class ProfileViewModel {
    weak var view: ProfileViewInterface?
    private var userId: String?
    private let profileService: ProfileServiceProtocol
    private let friendsService: FriendsServiceProtocol
    private let presenceService: PresenceServiceProtocol
    private(set) var streakDates: [Date] = []
    
    private var isFetching = false

    //MARK: - Init
    init(profileService: ProfileServiceProtocol,friendsService: FriendsServiceProtocol, presenceService: PresenceServiceProtocol, userId: String?) {
        if let userId = userId{
            self.userId = userId
        }
        self.profileService = profileService
        self.friendsService = friendsService
        self.presenceService = presenceService
    }

    private func calculateStreakDates(from dates: [Date]) -> [Date] {
        let sortedDates = dates.sorted()
        var streak: [Date] = []
        for i in 1..<sortedDates.count {
            let previous = sortedDates[i - 1]
            let current = sortedDates[i]
            let diff = Calendar.current.dateComponents([.day], from: previous, to: current).day ?? 0
            if diff == 1 {
                if !streak.contains(previous) {
                    streak.append(previous)
                }
                streak.append(current)
            }
        }
        return streak
    }

}

extension ProfileViewModel: ProfileViewModelInterface {
    
    func viewDidLoad() {
        guard !isFetching else { return }
        
        if userId == nil {
            if let uid = Auth.auth().currentUser?.uid {
                userId = uid
                view?.setAddFriendButtonHidden(true)
                view?.setMenuButtonHidden(false)
            } else {
                view?.showMessage(Constants.ValidationMessages.friendRequestSent, type: .success)
                return
            }
        } else if userId != Auth.auth().currentUser?.uid {
            view?.setAddFriendButtonHidden(false)
            view?.setMenuButtonHidden(true)
        }

        isFetching = true
        view?.showLoading(true)
        
        let group = DispatchGroup()

        // Profil çekme işlemi
        group.enter()
        profileService.fetchProfile(userId: userId) { [weak self] result in
            guard let self = self else { group.leave(); return }
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.view?.updateNickname(profile.nickname)
                    if let profileImageUrl = profile.profileImageURL,
                       let url = URL(string: profileImageUrl) {
                        self.view?.updateProfileImage(with: url)
                    }
                    if let averageWorkTime = profile.averageWorkTime {
                        let formatted = String(format: "Average Work Hour: %.2f", (averageWorkTime / 60 / 60))
                        self.view?.updateAverageWorkTime(formatted)
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.view?.showMessage(Constants.ValidationMessages.friendRequestError, type: .error)
                }
            }
            group.leave()
        }

        // Arkadaşlık durumu kontrolü (giriş yapan kişi farklıysa)
        if let currentUserId = Auth.auth().currentUser?.uid,
           let userId = userId,
           currentUserId != userId {
            
            group.enter()
            friendsService.checkFriendshipStatus(between: currentUserId, and: userId) { [weak self] result in
                guard let self = self else { group.leave(); return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let status):
                        self.view?.configureAddFriendButton(status)
                    case .failure(let error):
                        self.view?.showMessage(error.localizedDescription, type: .error)
                    }
                }
                group.leave()
            }
        }

        // Tüm işlemler bittiğinde
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.view?.showLoading(false)
            self.isFetching = false
        }
        
        
        //MARK: - TEST
        //        DispatchQueue.main.async {
        //
        //            let calendar = Calendar.current
        //            let today = Date()
        //            let exampleDates: [Date] = [
        //                today,
        //                calendar.date(byAdding: .day, value: -1, to: today)!,
        //                calendar.date(byAdding: .day, value: -2, to: today)!,
        //                calendar.date(byAdding: .day, value: -3, to: today)!
        //            ]
        //            self.streakDates = self.calculateStreakDates(from: exampleDates)
        //
        //            self.view?.updateStreakCalendar()
        //        }
    }
    
    func isDatePartOfStreak(_ date: Date) -> Bool {
        return streakDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
    
    func isDateConnectedLeft(_ date: Date) -> Bool {
        guard let previous = Calendar.current.date(byAdding: .day, value: -1, to: date) else { return false }
        return isDatePartOfStreak(previous)
    }
    
    func isDateConnectedRight(_ date: Date) -> Bool {
        guard let next = Calendar.current.date(byAdding: .day, value: 1, to: date) else { return false }
        return isDatePartOfStreak(next)
    }
    
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            
            view?.navigateToLogin()
        } catch {
            view?.showMessage(Constants.ValidationMessages.logoutError, type: .error)
        }
    }
    
    func addFriendTapped() {
        if let currentUserId = Auth.auth().currentUser?.uid, let userId = userId, currentUserId != userId {
            view?.showLoading(true)

            friendsService.sendFriendRequest(from: currentUserId, to: userId) {[weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.view?.showLoading(false)
                    switch result {
                    case .success:
                        self.view?.showMessage(Constants.ValidationMessages.friendRequestSent, type: .success)
                    case .failure(_):
                        self.view?.showMessage(Constants.ValidationMessages.friendRequestError, type: .error)
                    }
                }
            }
        } else {
            view?.showMessage(Constants.ValidationMessages.notLoggedIn, type: .error)
        }
    }
}
    

