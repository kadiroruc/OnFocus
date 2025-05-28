//
//  ProfileVewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 17.05.2025.
//

import Foundation
import UIKit

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
    private let profileService: ProfileServiceProtocol
    private(set) var streakDates: [Date] = []
    
    private var isFetching = false

    //MARK: - Init
    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
    }

    func viewDidLoad() {
        
        guard !isFetching else { return } // if there is fetch operation , dont start
        isFetching = true
        DispatchQueue.global(qos: .background).async {[weak self] in
            guard let self = self else {return}
            
            self.profileService.fetchProfile { result in
                switch result {
                case .success(let profile):
                    DispatchQueue.main.async {
                        self.view?.updateNickname(profile.nickname)
                        if let profileImageUrl = profile.profileImageUrl,
                           let url = URL(string: profileImageUrl) {
                            self.view?.updateProfileImage(with: url )
                        }

                        //self.view?.updateAverageWorkTime("Average Work Hour: \(profile.averageWorkTime)")
                        //self.view?.updateStreakDay(profile.currentStreakCount)
                        //self.view?.updateProfileImage(with: profile.image)
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

