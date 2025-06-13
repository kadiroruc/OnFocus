//
//  LeaderboardService.swift
//  Test
//
//  Created by Abdulkadir Oruç on 11.06.2025.
//

import Foundation

protocol LeaderboardServiceProtocol{
    var profileUserId: String? { get }
    
    func fetchWeeklyLeaderboard(from date: Date,
                                completion: @escaping (Result<[ProfileModel], Error>) -> Void)
}

final class LeaderboardService: LeaderboardServiceProtocol {
    private let profileService: ProfileServiceProtocol
    private let friendsService: FriendsServiceProtocol
    private let timerService: TimerServiceProtocol
    
    init(profileService: ProfileServiceProtocol, friendsService: FriendsServiceProtocol, timerService: TimerServiceProtocol) {
        self.profileService = profileService
        self.friendsService = friendsService
        self.timerService = timerService
    }
    
    var profileUserId: String? {
        return profileService.currentUserId
    }
    
    func fetchWeeklyLeaderboard(from date: Date, completion: @escaping (Result<[ProfileModel], Error>) -> Void) {
        
        guard let userId = profileService.currentUserId else {
            //view?.showError(message: "User not found")
            return
        }
        
        profileService.fetchProfile(userId: userId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                self.friendsService.fetchFriends(for: userId) { result in
                    switch result {
                    case .success(let friends):
                        let friendIDs = friends.compactMap { $0.id }
                        let allUserIDs = friendIDs + [userId]
                        var results: [ProfileModel] = (friends + [profile]).filter { $0.id != nil }
                        
                        let group = DispatchGroup()
                        
                        for (index, uid) in allUserIDs.enumerated() {
                            group.enter()
                            
                            self.timerService.fetchWeeklyStatistics(for: uid, from: date) { result in
                                defer { group.leave() }
                                
                                switch result {
                                case .success(let totalDuration):
                                    results[index].totalWorkTime = totalDuration
                                case .failure(let error):
                                    print("Statistic fetch error: \(error.localizedDescription)")
                                }
                            }
                        }
                        
                        group.notify(queue: .main) {
                            let sorted = results
                                .filter { $0.totalWorkTime != nil }
                                .sorted { ($0.totalWorkTime ?? 0) > ($1.totalWorkTime ?? 0) }
                                .prefix(10)
                            completion(.success(Array(sorted)))
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
//        friendsService.fetchFriends(for: userId) { [weak self] result in
//            guard let self = self else { return }
//            
//            switch result {
//            case .success(let friends):
//                let friendIDs = friends.map { $0.id } // [String]
//                let allUsers = friendIDs + [userId]   // [String], user dahil
//                let results = friends + [ProfileModel(id: userId, nickname: "", totalWorkTime: 0, currentStreakCount: 0, profileImageURL: nil, status: nil)]
//                
//                let group = DispatchGroup()
//                
//                for (index,uid) in allUsers.enumerated() {
//                    group.enter()
//                    if let uid = uid{
//                        self.timerService.fetchWeeklyStatistics(for: uid, from: date) { statResult in
//                            switch statResult {
//                            case .success(let totalDuration):
//                                results[index].totalWorkTime = totalDuration
//                                
//                            case .failure(let error):
//                                print("Statistic fetch error: \(error.localizedDescription)")
//                                group.leave()
//                            }
//                        }
//                    }
//                    
//                }
//                
//                group.notify(queue: .main) {
//                    let sorted = results
//                        .filter { $0.totalWorkTime != nil }
//                        .sorted { ($0.totalWorkTime ?? 0) > ($1.totalWorkTime ?? 0) }
//                        .prefix(10)
//                    completion(.success(Array(sorted)))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
    }
    
    
}
