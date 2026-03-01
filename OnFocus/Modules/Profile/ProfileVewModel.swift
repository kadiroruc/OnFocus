//
//  ProfileVewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 17.05.2025.
//

import UIKit
import FirebaseAuth

// MARK: - ProfileViewModelInterface

protocol ProfileViewModelInterface {
    var view: ProfileViewInterface? { get set }
    
    func viewDidLoad()
    func isDatePartOfStreak(_ date: Date) -> Bool
    func isDateConnectedLeft(_ date: Date) -> Bool
    func isDateConnectedRight(_ date: Date) -> Bool
    func signOut()
    func addFriendTapped()
    func cancelFriendRequest()
    func setSelectedImage(_ image: UIImage)
        
}

// MARK: - ProfileViewModel

final class ProfileViewModel {
    weak var view: ProfileViewInterface?
    var userId: String?
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
    
    private(set) var streakDateSet: Set<Date> = []
    
    private func setStreakDates(from stringDates: [String]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.streakDateSet = Set(stringDates.compactMap { formatter.date(from: $0) })
    }
    
    private func calculateCurrentStreakCount(from streakDays: [String]) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateSet: Set<Date> = Set(streakDays.compactMap { formatter.date(from: $0)?.stripTime() })
        guard !dateSet.isEmpty else { return 0 }

        var count = 0
        var currentDate = Date().stripTime()

        while dateSet.contains(currentDate) {
            count += 1
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        }

        return count
    }

}

extension ProfileViewModel: ProfileViewModelInterface {
    func setSelectedImage(_ image: UIImage) {
        profileService.updateProfileImage(image) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success():
                DispatchQueue.main.async {
                    self.view?.showMessage(Constants.ValidationMessages.profileImageUpdated, type: .success)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.view?.showMessage(Constants.ValidationMessages.profileImageUpdateError, type: .error)
                }
            }
        }
    }
    
    func cancelFriendRequest() {
        if let currentUserId = Auth.auth().currentUser?.uid, let userId = userId, currentUserId != userId {
            view?.showLoading(true)
            
            friendsService.cancelFriendRequest(from: currentUserId, to: userId) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.view?.showLoading(false)
                    switch result {
                    case .success:
                        self.view?.showMessage(Constants.ValidationMessages.friendRequestCancelled, type: .success)
                        self.view?.configureAddFriendButton("")
                    case .failure:
                        self.view?.showMessage(Constants.ValidationMessages.friendRequestCancelledError, type: .error)
                    }
                }
            }
        } else {
            view?.showMessage(Constants.ValidationMessages.notLoggedIn, type: .error)
        }

    }
    
    
    func viewDidLoad() {
        guard !isFetching else { return }
        
        if userId == nil || userId == profileService.currentUserId {
            if let uid = profileService.currentUserId {
                userId = uid
                view?.setAddFriendButtonHidden(true)
                view?.setMenuButtonHidden(false)
            } else {
                view?.showMessage(Constants.ValidationMessages.friendRequestSent, type: .success)
                return
            }
        } else if userId != profileService.currentUserId {
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
                    if let nickname = profile.nickname{
                        self.view?.updateNickname(nickname)
                    }else{
                        self.view?.navigateToFillProfile()
                    }
                    if let profileImageUrl = profile.profileImageURL,
                       let url = URL(string: profileImageUrl) {
                        self.view?.updateProfileImage(with: url)
                    }
                    if profile.totalWorkTime != nil {
                        self.view?.updateTotalWorkTime(L10n.Profile.totalWorkHour(profile.totalWorkTimeFormatted))
                    }
                    
                    if let streakDays = profile.streakDays{
                        self.setStreakDates(from: streakDays)
                        self.view?.reloadStreakCalendar()
                        let currentStreakCount = self.calculateCurrentStreakCount(from: streakDays)
                        self.view?.updateStreakDayLabel(currentStreakCount)
                    }
                }
            case .failure(_):
                
                print("Profile fetch error")
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
        return streakDateSet.contains(date.stripTime())
    }

    func isDateConnectedLeft(_ date: Date) -> Bool {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        return streakDateSet.contains(yesterday.stripTime())
    }

    func isDateConnectedRight(_ date: Date) -> Bool {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        return streakDateSet.contains(tomorrow.stripTime())
    }
    
    
    func signOut() {
        presenceService.setUserStatus(online: false)
        
        do {
            try Auth.auth().signOut()
            NotificationCenter.default.post(name: .userDidSignOut, object: nil)
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
                        self.view?.configureAddFriendButton(Constants.Firebase.pending)
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
    
