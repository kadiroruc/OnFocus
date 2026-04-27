//
//  AppDelegate.swift
//  Test
//
//  Created by Abdulkadir Oruç on 5.02.2025.
//

import UIKit
import Firebase
import UserNotifications
#if targetEnvironment(macCatalyst)
import ServiceManagement
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    #if targetEnvironment(macCatalyst)
    private let timerMenuIdentifier = UIMenu.Identifier("com.abdulkadiroruc.onfocus.timer")
    #endif

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        NetworkMonitor.shared.start()
        
        // Set notification center delegate
        UNUserNotificationCenter.current().delegate = self
        AppTimerMenuBridge.shared.startListeningForSharedChanges()

        #if targetEnvironment(macCatalyst)
        MenuBarHelperLauncher.activateIfNeeded()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rebuildMacTimerMenu),
            name: .appTimerMenuStateDidChange,
            object: nil
        )
        UIMenuSystem.main.setNeedsRebuild()
        #endif
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // Show notifications as banner and play sound even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
    
    #if targetEnvironment(macCatalyst)
    override func buildMenu(with builder: UIMenuBuilder) {
        guard builder.system == .main else { return }

        super.buildMenu(with: builder)

        if builder.menu(for: timerMenuIdentifier) != nil {
            builder.remove(menu: timerMenuIdentifier)
        }

        let state = AppTimerMenuBridge.shared.state
        let detailCommand = UICommand(
            title: "\(state.detailText) • \(state.displayTime)",
            action: #selector(noopTimerMenuAction),
            attributes: [.disabled]
        )
        let primaryCommand = UICommand(
            title: state.primaryActionTitle,
            action: #selector(togglePrimaryAction),
            propertyList: nil
        )
        let saveCommand = UICommand(
            title: "Kaydet",
            action: #selector(saveSession),
            propertyList: nil,
            attributes: state.canSave ? [] : [.disabled]
        )
        let cancelCommand = UICommand(
            title: "Iptal Et",
            action: #selector(cancelSession),
            propertyList: nil,
            attributes: state.canCancel ? [] : [.disabled]
        )

        let timerMenu = UIMenu(
            title: "Timer",
            identifier: timerMenuIdentifier,
            children: [detailCommand, primaryCommand, saveCommand, cancelCommand]
        )

        if builder.menu(for: .application) != nil {
            builder.insertChild(timerMenu, atEndOfMenu: .application)
        } else if builder.menu(for: .file) != nil {
            builder.insertChild(timerMenu, atEndOfMenu: .file)
        } else {
            builder.insertSibling(timerMenu, afterMenu: .view)
        }
    }

    @objc private func rebuildMacTimerMenu() {
        UIMenuSystem.main.setNeedsRebuild()
    }

    @objc private func togglePrimaryAction() {
        AppTimerMenuBridge.shared.request(.togglePrimaryAction)
    }

    @objc private func saveSession() {
        AppTimerMenuBridge.shared.request(.saveSession)
    }

    @objc private func cancelSession() {
        AppTimerMenuBridge.shared.request(.cancelSession)
    }

    @objc private func noopTimerMenuAction() {}
    #endif
}

#if targetEnvironment(macCatalyst)
private enum MenuBarHelperLauncher {
    private static let bundleIdentifier = "com.abdulkadiroruc.OnFocusMenuBar"
    private static let helperAppName = "OnFocusMenuBar.app"

    static func activateIfNeeded() {
        registerForLaunchAtLogin()
        launchBundledHelperIfNeeded()
    }

    private static func registerForLaunchAtLogin() {
        guard #available(macCatalyst 16.0, *) else { return }

        let service = SMAppService.loginItem(identifier: bundleIdentifier)
        guard service.status == .notRegistered else { return }

        do {
            try service.register()
        } catch {
            #if DEBUG
            print("Failed to register menu bar helper: \(error)")
            #endif
        }
    }

    private static func launchBundledHelperIfNeeded() {
        guard let helperURL = bundledHelperURL() else { return }
        UIApplication.shared.open(helperURL, options: [:], completionHandler: nil)
    }

    private static func bundledHelperURL() -> URL? {
        let fileManager = FileManager.default
        let candidateURLs = [
            Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LoginItems/\(helperAppName)"),
            Bundle.main.bundleURL.appendingPathComponent("Library/LoginItems/\(helperAppName)")
        ]

        return candidateURLs.first { fileManager.fileExists(atPath: $0.path) }
    }
}
#endif
