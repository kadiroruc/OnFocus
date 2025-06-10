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
    func toggleCountdown()
    func viewDidLoad()
    func startCountdown()
    func pauseCountdown()
    func resumeCountdown()
    func updateCountdown()
    func cancelButtonTapped()
    func cancelConfirmButtonTapped()
}

final class HomeViewModel {
    weak var view: HomeViewInterface?
    private let timerService: TimerServiceProtocol
    private let friends: [ProfileModel] = []
    
    init(timerService: TimerServiceProtocol) {
        self.timerService = timerService
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
        
}

extension HomeViewModel: HomeViewModelInterface{
    func viewDidLoad() {
        view?.updateCountdownLabel(minutes: countdownMinutes, seconds: countdownSeconds)
        
        
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
