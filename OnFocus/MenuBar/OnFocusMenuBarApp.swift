import AppKit
import SwiftUI

@main
struct OnFocusMenuBarApp: App {
    @NSApplicationDelegateAdaptor(OnFocusMenuBarAppDelegate.self) private var appDelegate
    @StateObject private var controller = MenuBarTimerController()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(controller: controller)
                .frame(width: 340)
        } label: {
            if controller.state.isRunning {
                Text(controller.state.displayTime)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            } else {
                Label(controller.menuBarTitle, systemImage: controller.menuBarSymbol)
            }
        }
        .menuBarExtraStyle(.window)
    }
}

final class OnFocusMenuBarAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppTimerMenuBridge.shared.startListeningForSharedChanges()
        AppTimerMenuBridge.shared.refreshSharedState()
    }
}
