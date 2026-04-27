import AppKit
import Combine
import Foundation

final class MenuBarTimerController: ObservableObject {
    @Published private(set) var state = AppTimerMenuBridge.shared.state

    private var observers: [NSObjectProtocol] = []

    init() {
        AppTimerMenuBridge.shared.startListeningForSharedChanges()
        AppTimerMenuBridge.shared.refreshSharedState()

        observers.append(
            NotificationCenter.default.addObserver(
                forName: .appTimerMenuStateDidChange,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.state = AppTimerMenuBridge.shared.state
            }
        )
    }

    deinit {
        observers.forEach(NotificationCenter.default.removeObserver)
    }

    var menuBarTitle: String {
        state.isRunning ? state.displayTime : "\(state.compactTitle) \(state.displayTime)"
    }

    var menuBarSymbol: String {
        switch state.mode {
        case .pomodoro:
            return state.isRunning ? "timer" : "timer.circle"
        case .timekeeper:
            return state.isRunning ? "stopwatch.fill" : "stopwatch"
        }
    }

    func triggerPrimaryAction() {
        AppTimerMenuBridge.shared.request(.togglePrimaryAction)
    }

    func saveSession() {
        AppTimerMenuBridge.shared.request(.saveSession)
    }

    func cancelSession() {
        AppTimerMenuBridge.shared.request(.cancelSession)
    }

    func openMainApp() {
        guard let url = URL(string: "onfocus://timer") else { return }
        NSWorkspace.shared.open(url)
    }

    func quit() {
        NSApp.terminate(nil)
    }
}
