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
}

// MARK: - ProfileViewModel

final class ProfileViewModel: ProfileViewModelInterface {
    weak var view: ProfileViewInterface?
    private var userId: String?
    private let profileService: ProfileServiceProtocol
    private(set) var streakDates: [Date] = []
    
    private var isFetching = false

    //MARK: - Init
    init(profileService: ProfileServiceProtocol, userId: String?) {
        if let userId = userId{
            self.userId = userId
        }
        self.profileService = profileService
    }

    func viewDidLoad() {
        
        guard !isFetching else { return } // if there is fetch operation , dont start
        if userId == nil{
            if let uid = Auth.auth().currentUser?.uid{
                userId = uid
                view?.setAddFriendButtonHidden(true)
            }else{
                view?.showError(Constants.ValidationMessages.notLoggedIn)
            }
        }else if userId != Auth.auth().currentUser?.uid {
            view?.setAddFriendButtonHidden(false)
        }
        
        isFetching = true
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else {return}
            
            self.profileService.fetchProfile(userId: userId) { result in
                switch result {
                case .success(let profile):
                    DispatchQueue.main.async {
                        self.view?.updateNickname(profile.nickname)
                        if let profileImageUrl = profile.profileImageURL,
                           let url = URL(string: profileImageUrl) {
                            self.view?.updateProfileImage(with: url )
                        }
                        if let averageWorkTime = profile.averageWorkTime{
                            let averageWorkTimeString = String(format: "Average Work Hour: %.2f", (averageWorkTime/60/60))
                            self.view?.updateAverageWorkTime(averageWorkTimeString)
                        }

                        //self.view?.updateStreakDay(profile.currentStreakCount)
                        //self.streakDates = self.calculateStreakDates(from: profile.streakRawDates)
                        //self.view?.updateStreakCalendar()
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.view?.showError(error.localizedDescription)
                    }
                }
            }
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
}

