//
//  LeaderboardService.swift
//  Test
//
//  Created by Abdulkadir Oruç on 11.06.2025.
//

import Foundation
import FirebaseAuth

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
        
        guard let userId = profileService.currentUserId else { return }

        profileService.fetchProfile(userId: userId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let profile):
                self.friendsService.fetchFriends(for: userId) { result in
                    switch result {
                    case .success(let friends):
                        let allProfiles = friends + [profile]
                        var profileDict: [String: ProfileModel] = [:]
                        allProfiles.forEach { if let id = $0.id { profileDict[id] = $0 } }

                        let group = DispatchGroup()
                        for uid in profileDict.keys {
                            group.enter()
                            self.timerService.fetchWeeklyStatistics(for: uid, from: date) { statResult in
                                defer { group.leave() }
                                if case .success(let duration) = statResult {
                                    profileDict[uid]?.totalWorkTime = duration
                                }
                            }
                        }

                        group.notify(queue: .main) {
                            let sorted = profileDict.values
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
    }
    
    
}
