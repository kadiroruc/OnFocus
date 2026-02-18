//
//  LeaderboardViewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 11.06.2025.
//

import Foundation

protocol LeaderboardViewModelInterface {
    var view: LeaderboardViewInterface? { get set }
    
    func viewDidLoad()
    var profiles: [ProfileModel] { get }
}

final class LeaderboardViewModel {
    weak var view: LeaderboardViewInterface?
    private(set) var profiles: [ProfileModel] = []
    
    private let leaderboardService: LeaderboardServiceProtocol
    
    init(leaderboardService: LeaderboardServiceProtocol) {
        self.leaderboardService = leaderboardService
    }
    
    private func calculatePercentile(currentUserTime: Int, others: [ProfileModel]) -> Int {
        // Geçerli olmayan verileri filtrele
        let validTimes = others.compactMap { $0.totalWorkTime }
        
        guard validTimes.count > 1 else {
            return 100 // Eğer kimse yoksa, kullanıcı en iyidir :)
        }

        // Daha az süreye sahip kaç kişi var?
        let countLess = validTimes.filter { currentUserTime > $0 }.count

        if others.count == 0 {
            return 100 // Eğer hiç kimse yoksa, kullanıcı en iyidir :)
        }
            
        // Yüzdeyi hesapla
        let percentage = Double(countLess) / Double(validTimes.count - 1) * 100 //Kendisi hariç
        return Int(percentage.rounded())
    }
    
    
}

extension LeaderboardViewModel: LeaderboardViewModelInterface {
    func viewDidLoad() {
        
        view?.showLoading(true)
        leaderboardService.fetchWeeklyLeaderboard(from: Date()) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let profiles):
                self.view?.showLoading(false)
                let topThree = Array(profiles.prefix(3))
                let others = Array(profiles.dropFirst(3))
                self.profiles = profiles
                
                view?.showTopThreeProfiles(topThree)
                view?.showOtherProfiles(others)
                
                if let currentUserId = leaderboardService.profileUserId{
                    for (index, profile) in profiles.enumerated(){
                        if profile.id == currentUserId {
                            self.view?.updateStateRankLabel(String(index + 1))
                            
                            let percentile = self.calculatePercentile(currentUserTime: profile.totalWorkTime ?? 0, others: self.profiles)
                            self.view?.updateStateLabel(percentile)
                        }
                    }
                }
                

            case .failure(let error):
                self.view?.showLoading(false)
                //self.view?.showError(message: error.localizedDescription)
            }

        }
        
        
    }
    
}
