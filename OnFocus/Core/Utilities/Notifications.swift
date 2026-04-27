import CoreFoundation
import Foundation

extension Notification.Name {
    static let pendingSessionsSynced = Notification.Name("pendingSessionsSynced")
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
    static let timekeeperAutoSaved = Notification.Name("timekeeperAutoSaved")
    static let userDidSignOut = Notification.Name("userDidSignOut")
    static let appTimerMenuStateDidChange = Notification.Name("appTimerMenuStateDidChange")
    static let appTimerMenuCommandRequested = Notification.Name("appTimerMenuCommandRequested")
}

enum AppTimerMenuMode: String, Codable, Equatable {
    case pomodoro
    case timekeeper
}

enum AppTimerMenuCommand: String, Codable {
    case togglePrimaryAction
    case saveSession
    case cancelSession
    case showMainWindow
}

struct AppTimerMenuState: Codable, Equatable {
    let mode: AppTimerMenuMode
    let compactTitle: String
    let displayTime: String
    let detailText: String
    let primaryActionTitle: String
    let isRunning: Bool
    let canSave: Bool
    let canCancel: Bool

    static let initial = AppTimerMenuState(
        mode: .pomodoro,
        compactTitle: "Odak",
        displayTime: "25:00",
        detailText: "Hazir",
        primaryActionTitle: "Baslat",
        isRunning: false,
        canSave: false,
        canCancel: false
    )
}

private struct AppTimerMenuCommandMessage: Codable, Equatable {
    let id: String
    let command: AppTimerMenuCommand
    let requestedAt: Date
}

final class AppTimerMenuBridge {
    static let shared = AppTimerMenuBridge()

    enum SharedKeys {
        static let appGroupIdentifier = "group.com.abdulkadiroruc.OnFocus.shared"
        static let stateData = "shared.timer.menu.state"
        static let commandData = "shared.timer.menu.command"
        static let stateDarwinNotification = "com.abdulkadiroruc.OnFocus.timer.state.changed"
        static let commandDarwinNotification = "com.abdulkadiroruc.OnFocus.timer.command.changed"
    }

    private let sharedDefaults = UserDefaults(suiteName: SharedKeys.appGroupIdentifier) ?? .standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var isListeningForSharedChanges = false
    private var lastCommandIdentifier: String?

    private(set) var state: AppTimerMenuState

    private init() {
        state = Self.loadPersistedState(from: sharedDefaults) ?? .initial
    }

    func update(state newState: AppTimerMenuState) {
        guard state != newState else { return }
        state = newState
        persistSharedState(newState)
        NotificationCenter.default.post(name: .appTimerMenuStateDidChange, object: nil)
    }

    func request(_ command: AppTimerMenuCommand) {
        let message = AppTimerMenuCommandMessage(
            id: UUID().uuidString,
            command: command,
            requestedAt: Date()
        )
        persistCommand(message)
        lastCommandIdentifier = message.id
        NotificationCenter.default.post(
            name: .appTimerMenuCommandRequested,
            object: nil,
            userInfo: ["command": command.rawValue]
        )
    }

    func startListeningForSharedChanges() {
        guard !isListeningForSharedChanges else { return }
        isListeningForSharedChanges = true

        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        CFNotificationCenterAddObserver(
            center,
            observer,
            { _, observer, name, _, _ in
                guard let observer,
                      let rawName = name?.rawValue as String? else { return }
                let bridge = Unmanaged<AppTimerMenuBridge>.fromOpaque(observer).takeUnretainedValue()
                bridge.handleDarwinNotification(named: rawName)
            },
            SharedKeys.stateDarwinNotification as CFString,
            nil,
            .deliverImmediately
        )

        CFNotificationCenterAddObserver(
            center,
            observer,
            { _, observer, name, _, _ in
                guard let observer,
                      let rawName = name?.rawValue as String? else { return }
                let bridge = Unmanaged<AppTimerMenuBridge>.fromOpaque(observer).takeUnretainedValue()
                bridge.handleDarwinNotification(named: rawName)
            },
            SharedKeys.commandDarwinNotification as CFString,
            nil,
            .deliverImmediately
        )
    }

    func refreshSharedState() {
        guard let sharedState = Self.loadPersistedState(from: sharedDefaults) else { return }
        guard state != sharedState else { return }
        state = sharedState
        NotificationCenter.default.post(name: .appTimerMenuStateDidChange, object: nil)
    }

    private func persistSharedState(_ newState: AppTimerMenuState) {
        guard let data = try? encoder.encode(newState) else { return }
        sharedDefaults.set(data, forKey: SharedKeys.stateData)
        sharedDefaults.synchronize()
        postDarwinNotification(named: SharedKeys.stateDarwinNotification)
    }

    private func persistCommand(_ message: AppTimerMenuCommandMessage) {
        guard let data = try? encoder.encode(message) else { return }
        sharedDefaults.set(data, forKey: SharedKeys.commandData)
        sharedDefaults.synchronize()
        postDarwinNotification(named: SharedKeys.commandDarwinNotification)
    }

    private func handleDarwinNotification(named name: String) {
        if name == SharedKeys.stateDarwinNotification {
            refreshSharedState()
            return
        }

        guard name == SharedKeys.commandDarwinNotification,
              let message = loadLatestCommand(),
              message.id != lastCommandIdentifier else {
            return
        }

        lastCommandIdentifier = message.id
        NotificationCenter.default.post(
            name: .appTimerMenuCommandRequested,
            object: nil,
            userInfo: ["command": message.command.rawValue]
        )
    }

    private func loadLatestCommand() -> AppTimerMenuCommandMessage? {
        guard let data = sharedDefaults.data(forKey: SharedKeys.commandData) else { return nil }
        return try? decoder.decode(AppTimerMenuCommandMessage.self, from: data)
    }

    private static func loadPersistedState(from defaults: UserDefaults) -> AppTimerMenuState? {
        guard let data = defaults.data(forKey: SharedKeys.stateData) else { return nil }
        return try? JSONDecoder().decode(AppTimerMenuState.self, from: data)
    }

    private func postDarwinNotification(named name: String) {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(center, CFNotificationName(name as CFString), nil, nil, true)
    }
}
