//
//  HomeViewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 3.03.2025.
//

import UIKit
import FirebaseAuth

protocol HomeViewModelInterface: AnyObject {
    var view: HomeViewInterface? { get set }
    var animationRunning: Bool { get set}
    var friends: [ProfileModel] { get }
    
    func toggleCountdown()
    func viewDidLoad()
    func startCountdown()
    func pauseCountdown()
    func resumeCountdown()
    func updateCountdown()
    func cancelButtonTapped()
    func cancelConfirmButtonTapped()
    func numberOfFriends() -> Int
    func didSelectFriend(at index: Int)
        
}

final class HomeViewModel {
    weak var view: HomeViewInterface?
    private let timerService: TimerServiceProtocol
    private let friendsService: FriendsServiceProtocol
    private(set) var friends: [ProfileModel] = []
    
    init(timerService: TimerServiceProtocol, friendsService: FriendsServiceProtocol) {
        self.timerService = timerService
        self.friendsService = friendsService
    }
    
    var animationRunning = false
    
    private var countdownMinutes = 0
    private var countdownSeconds = 1
    private var splitSeconds = 59
    
    private var isPaused: Bool = true
    private var countdownTimer: Timer?
    private var sessionCount = 1
    private var isSessionCompleted = true
    private var isBreak = false
    
    
    func resetTimer() {
        countdownTimer?.invalidate()
        isPaused = true
        animationRunning = false
        view?.updatePlayButton(isPaused: true)
        view?.resetCircularAnimationToStart(isSessionCompleted)
        
        if isSessionCompleted {
            sessionCount += 1
            view?.updateSessionsLabel(text: "Break")
            if sessionCount == 5 {
                countdownMinutes = 0
                countdownSeconds = 3
                splitSeconds = 59
                
                sessionCount = 1
                view?.updateSessionsLabel(text: "Break")
            }else{
                countdownMinutes = 0
                countdownSeconds = 1
                splitSeconds = 59
            }
            isSessionCompleted = false
            isBreak = true
                
        }else{
            
            view?.updateSessionsLabel(text: "\(sessionCount) of 4 Sessions")
            countdownMinutes = 0
            countdownSeconds = 2
            splitSeconds = 59
            isSessionCompleted = true
            isBreak = false
        }

        view?.updateCountdownLabel(minutes: countdownMinutes, seconds: countdownSeconds)
    }
    
    func saveTimeToDatabase(if session:Bool) {
        guard session else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let test = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        let session = SessionModel(id: UUID().uuidString, duration: TimeInterval(25*60), timestamp: Date())
            
            
        Task {
            do {
                try await timerService.saveSession(session, userId: userId)
                try await timerService.updateAggregate(for: session, userId: userId)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        
    }
    
    private func fetchFriends(){
        if let currentUserId = Auth.auth().currentUser?.uid {
            friendsService.fetchFriends(for: currentUserId) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let friends):
                    self.friends = friends
                    
                    let onlineCount = friends.filter { ($0.status != nil) == true }.count
                    let totalCount = friends.count

                    self.view?.updateWorkingLabel(online: onlineCount, friends: totalCount)
                    self.view?.reloadData()
                case .failure(let error):
                    print("Error fetching friends: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchOnlinePeopleCount() {
        friendsService.fetchOnlineUserCount { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let count):
                self.view?.updateOnlinePeopleCount(count)
            case .failure(let error):
                print("Error fetching online people count: \(error.localizedDescription)")
            }
        }
    }
        
}

extension HomeViewModel: HomeViewModelInterface{
    func didSelectFriend(at index: Int) {
        view?.navigateToProfileDetail(userId: friends[index].id)
    }
    
    func numberOfFriends() -> Int {
        return friends.count
    }
    
    func viewDidLoad() {
        view?.updateCountdownLabel(minutes: countdownMinutes, seconds: countdownSeconds)
        
        fetchFriends()
        fetchOnlinePeopleCount()
        


        
    }
    
    func toggleCountdown() {
        if isPaused {
            if animationRunning{
                resumeCountdown()
            }else{
                startCountdown()
            }
        } else {
            pauseCountdown()
        }
        isPaused.toggle()

        view?.updatePlayButton(isPaused: isPaused)
    }
    
    func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        view?.startCircularAnimation(duration: TimeInterval(countdownMinutes * 60 + countdownSeconds))
        
    }
    
    func pauseCountdown() {
        countdownTimer?.invalidate()
        view?.pauseCircularAnimation()
    }
    
    func resumeCountdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        view?.resumeCircularAnimation()
    }
    
    @objc func updateCountdown() {
        if countdownMinutes == 0 && countdownSeconds == 0 {
            splitSeconds = 0
        }
        if countdownMinutes > 0 || countdownSeconds > 0 || splitSeconds > 0 {
            if splitSeconds == 0 {
                if countdownSeconds == 0 {
                    if countdownMinutes > 0 {
                        countdownMinutes -= 1
                        countdownSeconds = 59
                    }
                } else {
                    countdownSeconds -= 1
                }
                splitSeconds = 59
            } else {
                splitSeconds -= 1
            }
            view?.updateCountdownLabel(minutes: countdownMinutes, seconds: countdownSeconds)
        } else {
            saveTimeToDatabase(if: isSessionCompleted)
            resetTimer()
        }
    }
    
    func cancelButtonTapped(){
        if !isBreak{
            if !animationRunning{
                view?.showMessage(Constants.ValidationMessages.pleaseStartTimer)
                return
            }else{
                view?.showConfirm(Constants.ValidationMessages.skipSessionConfirmation)
            }
        }else{
            resetTimer()
        }
        
    }
    
    func cancelConfirmButtonTapped() {
        resetTimer()
    }
        
    
}
