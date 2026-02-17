//
//  HomeViewModel.swift
//  Test
//
//  Created by Abdulkadir Oruç on 3.03.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import UserNotifications

protocol HomeViewModelInterface {
    var view: HomeViewInterface? { get set }
    var animationRunning: Bool { get set}
    var friends: [ProfileModel] { get }
    
    func toggleCountdown()
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func startCountdown()
    func pauseCountdown()
    func resumeCountdown()
    func updateCountdown()
    func cancelButtonTapped()
    func cancelConfirmButtonTapped()
    func numberOfFriends() -> Int
    func didSelectFriend(at index: Int)
    func didChangeTimerMode(timeKeeperMode: Bool)
    func startTimeKeeper()
    func pauseTimeKeeper()
    func updateTimeKeeper()
    func stopButtonTapped()
        
}

final class HomeViewModel {
    weak var view: HomeViewInterface?
    private let timerService: TimerServiceProtocol
    private let friendsService: FriendsServiceProtocol
    private let profileService: ProfileServiceProtocol
    
    init(timerService: TimerServiceProtocol, friendsService: FriendsServiceProtocol, profileService: ProfileServiceProtocol) {
        self.timerService = timerService
        self.friendsService = friendsService
        self.profileService = profileService
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    private(set) var friends: [ProfileModel] = []
    var animationRunning = false
    private var countdownMinutes = 25
    private var countdownSeconds = 0
    private var splitSeconds = 59
    private var isPaused: Bool = true
    private var countdownTimer: Timer?
    private var sessionCount = 1
    private var isSessionCompleted = true
    private var isBreak = false
    private var isPomodoroMode: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: "isTimeKeeperModeOn")
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: "isTimeKeeperModeOn")
        }
    }
    private var timeKeeperStartDate: Date?
    private var timeKeeperElapsedTime: TimeInterval = 0
    private var timeKeeperTimer: Timer?
    private var backgroundEnteredDate: Date?
    private var remainingTimeWhenBackground: TimeInterval?
    private var friendsListener: FriendsListenerToken?
    private var onlineCountListener: ListenerRegistration?

    
    
    func resetTimer() {
        countdownTimer?.invalidate()
        isPaused = true
        animationRunning = false
        view?.updatePlayButton(isPaused: true)
        view?.resetCircularAnimationToStart(isSessionCompleted)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer_expired"])
        
        if isSessionCompleted {
            sessionCount += 1
            view?.updateSessionsLabel(text: "Break")
            if sessionCount == 5 {
                // 4 Pomodoro completed 15 minute break
                countdownMinutes = 15
                countdownSeconds = 0
                splitSeconds = 59
                
                sessionCount = 1
                view?.updateSessionsLabel(text: "Break")
            }else{
                // 25 minute session completed 5 minute break
                countdownMinutes = 5
                countdownSeconds = 0
                splitSeconds = 59
            }
            isSessionCompleted = false
            isBreak = true
                
        }else{
            //Sessions
            view?.updateSessionsLabel(text: "\(sessionCount) of 4 Sessions")
            countdownMinutes = 25
            countdownSeconds = 0
            splitSeconds = 59
            isSessionCompleted = true
            isBreak = false
        }

        view?.updateCountdownLabel(minutes: countdownMinutes, seconds: countdownSeconds)
    }
    
    func saveTimeToDatabase(if session:Bool) {
        guard session else { return }
        guard let userId = profileService.currentUserId else { return }
        
        //let test = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        let session: SessionModel
        if isPomodoroMode{
            session = SessionModel(id: UUID().uuidString, duration: TimeInterval(25*60), timestamp: Date())
        }else{
            session = SessionModel(id: UUID().uuidString, duration: TimeInterval(timeKeeperElapsedTime), timestamp: Date())
        }
        
            
            
        Task {
            do {
                try await timerService.saveSessionAndUpdateAggregates(session, userId: userId)
                checkAndUpdateProfileStreak()
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        
        
    }
    
    private func fetchFriends(){
        if let currentUserId = Auth.auth().currentUser?.uid {
            view?.showLoading(true)
            friendsService.fetchFriends(for: currentUserId) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let friends):
                    self.view?.showLoading(false)
                    self.friends = friends
                    
                    let onlineCount = friends.filter { ($0.status == "online") }.count
                    let totalCount = friends.count

                    self.view?.updateWorkingLabel(online: onlineCount, friends: totalCount)
                    self.view?.reloadData()
                case .failure(let error):
                    self.view?.showLoading(false)
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
    
    private func startObservers() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        if friendsListener == nil {
            view?.showLoading(true)
            friendsListener = friendsService.observeFriends(for: currentUserId) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let friends):
                        self.view?.showLoading(false)
                        self.friends = friends
                        
                        let onlineCount = friends.filter { ($0.status == "online") }.count
                        let totalCount = friends.count
                        self.view?.updateWorkingLabel(online: onlineCount, friends: totalCount)
                        self.view?.reloadData()
                    case .failure(let error):
                        self.view?.showLoading(false)
                        print("Error observing friends: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        if onlineCountListener == nil {
            onlineCountListener = friendsService.observeOnlineUserCount { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let count):
                        self.view?.updateOnlinePeopleCount(count)
                    case .failure(let error):
                        print("Error observing online people count: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func stopObservers() {
        friendsListener?.remove()
        friendsListener = nil
        
        onlineCountListener?.remove()
        onlineCountListener = nil
    }
    
    private func checkAndUpdateProfileStreak(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())

        let lastUpdateKey = "lastStreakUpdateDate"
        let lastUpdated = UserDefaults.standard.string(forKey: lastUpdateKey)

        if lastUpdated != todayString {
            profileService.updateStreakDay { result in
                switch result {
                case .success:
                    UserDefaults.standard.set(todayString, forKey: lastUpdateKey)
                case .failure(let error):
                    print("Streak update error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func resetTimeKeeper() {
        timeKeeperTimer?.invalidate()
        isPaused = true
        timeKeeperStartDate = nil
        timeKeeperElapsedTime = 0
        animationRunning = false
        view?.updateCountdownLabel(minutes: 0, seconds: 0)
        view?.updatePlayButton(isPaused: true)

    }
    private func scheduleTimerNotification(seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        if isSessionCompleted {
            content.title = "Session Complete!"
            content.body = "Time for a break."
        } else {
            content.title = "Break Over!"
            content.body = "Time to focus."
        }
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "timer_expired", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
        
}

extension HomeViewModel: HomeViewModelInterface{
    func stopButtonTapped() {
        if animationRunning{
            pauseTimeKeeper()
        }
        if !isPomodoroMode && timeKeeperElapsedTime == 0{
            self.view?.showMessage(Constants.ValidationMessages.pleaseStartTimer)
            return
        }

        saveTimeToDatabase(if: true)
        resetTimeKeeper()
    }
    
    func didChangeTimerMode(timeKeeperMode: Bool) {
        if timeKeeperMode {
            countdownTimer?.invalidate()
            isPaused = true
            animationRunning = false
            
            countdownMinutes = 0
            countdownSeconds = 0
            splitSeconds = 0
            
            view?.updateCountdownLabel(minutes: countdownMinutes, seconds: countdownSeconds)
            view?.updatePlayButton(isPaused: true)
            view?.resetCircularAnimationToStart(isSessionCompleted)
            
            view?.setCircularAnimation(hidden: true)
            view?.configurePlayAndStopButton(isPomodoroMode: isPomodoroMode)
        } else {
            countdownTimer?.invalidate()
            isPaused = true
            animationRunning = false
            isSessionCompleted = false
            
            countdownMinutes = 25
            countdownSeconds = 0
            splitSeconds = 59
            
            view?.updateCountdownLabel(minutes: countdownMinutes, seconds: countdownSeconds)
            view?.updatePlayButton(isPaused: true)
            view?.resetCircularAnimationToStart(isSessionCompleted)
            view?.setCircularAnimation(hidden: false)
            view?.configurePlayAndStopButton(isPomodoroMode: isPomodoroMode)
            
        }
        
        self.isPomodoroMode = !timeKeeperMode
    }
    
    func didSelectFriend(at index: Int) {
        view?.navigateToProfileDetail(userId: friends[index].id)
    }
    
    func numberOfFriends() -> Int {
        return friends.count
    }
    
    func viewDidLoad() {
        view?.updateCountdownLabel(minutes: countdownMinutes, seconds: countdownSeconds)
        if !isPomodoroMode{
            didChangeTimerMode(timeKeeperMode: true)
        }
    }
    
    func viewWillAppear() {
        startObservers()
    }
    
    func viewWillDisappear() {
        stopObservers()
    }
    
    
    func toggleCountdown() {
        if isPomodoroMode{
            if isPaused {
                if animationRunning{
                    resumeCountdown()
                }else{
                    startCountdown()
                }
            } else {
                pauseCountdown()
            }
        }else{
            //Timekeeper mode
            if isPaused {
                startTimeKeeper()
            } else {
                pauseTimeKeeper()
            }
        }

        isPaused.toggle()
        view?.updatePlayButton(isPaused: isPaused)
    }
    
    func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        view?.startCircularAnimation(duration: TimeInterval(countdownMinutes * 60 + countdownSeconds))
        
        scheduleTimerNotification(seconds: TimeInterval(countdownMinutes * 60 + countdownSeconds))
        
    }
    
    func pauseCountdown() {
        countdownTimer?.invalidate()
        view?.pauseCircularAnimation()
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer_expired"])
    }
    
    func resumeCountdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        view?.resumeCircularAnimation()
        
        let totalSeconds = countdownMinutes * 60 + countdownSeconds + splitSeconds / 60
        scheduleTimerNotification(seconds: TimeInterval(totalSeconds))
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
        if isPomodoroMode{
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
        }else{
            
            if !animationRunning {
                resetTimeKeeper()
                return
            } else {
                view?.showConfirm(Constants.ValidationMessages.resetTimeKeeperConfirmation)
            }
        }

    }
    
    func cancelConfirmButtonTapped() {
        if isPomodoroMode{
            resetPomodoroWithoutAdvancing()
        }else{
            resetTimeKeeper()
        }
        
    }
    
    
    func startTimeKeeper() {
        timeKeeperStartDate = Date()
        timeKeeperTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateTimeKeeper),
            userInfo: nil,
            repeats: true
        )
        animationRunning = true
    }

    func pauseTimeKeeper() {
        timeKeeperTimer?.invalidate()
        if let start = timeKeeperStartDate {
            timeKeeperElapsedTime += Date().timeIntervalSince(start)
        }
        animationRunning = false
    }

    @objc func updateTimeKeeper() {
        guard let start = timeKeeperStartDate else { return }
        let elapsed = timeKeeperElapsedTime + Date().timeIntervalSince(start)
        let totalSeconds = Int(elapsed)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        view?.updateCountdownLabel(minutes: minutes, seconds: seconds)
    }

    private func resetPomodoroWithoutAdvancing() {
        countdownTimer?.invalidate()
        isPaused = true
        animationRunning = false
        isBreak = false
        isSessionCompleted = false

        countdownMinutes = 0
        countdownSeconds = 7
        splitSeconds = 59

        view?.updateSessionsLabel(text: "\(sessionCount) of 4 Sessions")
        view?.updateCountdownLabel(minutes: countdownMinutes, seconds: countdownSeconds)
        view?.updatePlayButton(isPaused: true)
        view?.resetCircularAnimationToStart(isSessionCompleted)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer_expired"])
    }
    
    @objc private func appWillResignActive() {
        // Eğer timer çalışıyorsa kalan süreyi ve zamanı kaydet
        if !isPaused && animationRunning {
            if isPomodoroMode {
                // Pomodoro modunda kalan süreyi hesapla
                let totalSeconds = countdownMinutes * 60 + countdownSeconds + splitSeconds / 60
                remainingTimeWhenBackground = TimeInterval(totalSeconds)
            } else {
                // TimeKeeper modunda geçen süreyi kaydet
                if let start = timeKeeperStartDate {
                    timeKeeperElapsedTime += Date().timeIntervalSince(start)
                    timeKeeperStartDate = Date()
                }
            }
            backgroundEnteredDate = Date()
        }
    }
    // Uygulama tekrar öne gelince çağrılır
    @objc private func appDidBecomeActive() {
        guard let backgroundDate = backgroundEnteredDate else { return }
        let now = Date()
        let diff = now.timeIntervalSince(backgroundDate)
        if !isPaused && animationRunning {
            if isPomodoroMode {
                // Pomodoro modunda kalan süreyi güncelle
                if let remaining = remainingTimeWhenBackground {
                    let newRemaining = max(0, remaining - diff)
                    countdownMinutes = Int(newRemaining) / 60
                    countdownSeconds = Int(newRemaining) % 60
                    splitSeconds = 59
                    view?.updateCountdownLabel(minutes: countdownMinutes, seconds: countdownSeconds)
                    if newRemaining == 0 {
                        saveTimeToDatabase(if: isSessionCompleted)
                        resetTimer()
                    }
                }
            }
        }
        backgroundEnteredDate = nil
        remainingTimeWhenBackground = nil
    }
    
}
