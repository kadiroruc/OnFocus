//
//  SceneDelegate.swift
//  Test
//
//  Created by Abdulkadir Oruç on 5.02.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let container = DIContainer.shared


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        registerServices()
        registerViewModels()
        registerViewControllers()
        
        
        if Auth.auth().currentUser != nil {
            // Kullanıcı giriş yapmışsa ana sayfaya git
            window.rootViewController = MainTabBarBuilder.makeTabBar(using: container)
        } else {
            // Giriş yapmamışsa login ekranına git
            let loginVC: LoginViewController = container.resolve()
            window.rootViewController = UINavigationController(rootViewController: loginVC)
        }

        window.makeKeyAndVisible()
        self.window = window
        
        checkAppVersion()
    }
    
    func registerServices() {
        
        container.register { AuthService() as AuthServiceProtocol }
        
        container.register {
            ProfileService(networkManager: URLSessionNetworkManager.shared) as ProfileServiceProtocol
        }
        
        container.register {
            PresenceService(profileService: self.container.resolve()) as PresenceServiceProtocol
        }
        
        container.register { FriendsService() as FriendsServiceProtocol }
        container.register { TimerService() as TimerServiceProtocol }
        
        container.register {
            LeaderboardService(profileService: self.container.resolve(), friendsService: self.container.resolve(), timerService: self.container.resolve()) as LeaderboardServiceProtocol
        }
    }
    
    func registerViewModels(){
        
        container.register {
            LoginViewModel(authService: self.container.resolve(), presenceService: self.container.resolve(), profileService: self.container.resolve()) as LoginViewModelInterface
        }
        container.register {
            FillProfileViewModel(profileService: self.container.resolve(), presenceService: self.container.resolve()) as FillProfileViewModelInterface
        }
        container.register {
            HomeViewModel(timerService: self.container.resolve(), friendsService: self.container.resolve(), profileService: self.container.resolve()) as HomeViewModelInterface
        }
        container.register {
            LeaderboardViewModel(leaderboardService: self.container.resolve()) as LeaderboardViewModelInterface
        }
        container.register {
            NotificationsViewModel(friendsService: self.container.resolve(), profileService: self.container.resolve()) as NotificationsViewModelInterface
        }
        container.register {
            ProfileViewModel(profileService: self.container.resolve(), friendsService: self.container.resolve(), presenceService: self.container.resolve(), userId: nil) as ProfileViewModelInterface
        }
        container.register {
            ProfileSearchViewModel(profileService: self.container.resolve()) as ProfileSearchViewModelInterface
        }
        container.register {
            SettingsViewModel(profileService: self.container.resolve()) as SettingsViewModelInterface
        }
        container.register {
            SignUpViewModel(authService: self.container.resolve()) as SignUpViewModelInterface
        }
        container.register {
            StatisticsViewModel(timerService: self.container.resolve()) as StatisticsViewModelInterface
        }
    }
    
    func registerViewControllers() {
        container.register { FillProfileViewController(viewModel: self.container.resolve()) }
        container.register { HomeViewController(viewModel: self.container.resolve()) }
        container.register { LeaderboardViewController(viewModel: self.container.resolve()) }
        container.register { LoginViewController(viewModel: self.container.resolve()) }
        container.register { NotificationsViewController(viewModel: self.container.resolve()) }
        container.register { ProfileViewController(viewModel: self.container.resolve()) }
        container.register { ProfileSearchViewController(viewModel: self.container.resolve()) }
        container.register { SettingsViewController(viewModel: self.container.resolve()) }
        container.register { SignUpViewController(viewModel: self.container.resolve()) }
        container.register { StatisticsViewController(viewModel: self.container.resolve()) }
    }
    
    // Firestore ile bağlantı ve sürüm kontrolü
    func checkAppVersion() {
        // Mevcut sürüm
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let db = Firestore.firestore()
        
        // Firestore'dan sürüm bilgisini al
        db.collection("app_versions").document("version_info").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let minimumVersion = data?["minimum_version"] as? String
                let appStoreURL = data?["app_store_url"] as? String

                // Eğer mevcut sürüm minimum sürümden küçükse, kullanıcıyı güncellemeye yönlendir
                if let minimumVersion = minimumVersion, let currentVersion = currentVersion, currentVersion < minimumVersion {
                    // Active view controller'ı al
                    if let rootViewController = self.getRootViewController() {
                        self.promptUserToUpdate(appStoreURL: appStoreURL ?? "", from: rootViewController)
                    }
                }
            } else {
                print("Error getting document: \(String(describing: error))")
            }
        }
    }

    // Kullanıcıya güncelleme bildirimi gösterme
    func promptUserToUpdate(appStoreURL: String, from viewController: UIViewController) {
        let alert = UIAlertController(title: "Update Required", message: "Please update the app to the latest version.", preferredStyle: .alert)
        let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
            if let url = URL(string: appStoreURL) {
                UIApplication.shared.open(url)
            }
        }
        alert.addAction(updateAction)
        viewController.present(alert, animated: true)
    }

    // Mevcut root view controller'ı almak için yardımcı metot
    func getRootViewController() -> UIViewController? {
        // iOS 15 ve sonrası için, doğru UIWindowScene üzerinden erişim sağla
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            // En aktif (key) olan pencereyi al
            if let window = scene.windows.first(where: { $0.isKeyWindow }) {
                return window.rootViewController
            }
        }
        return nil
    }
        

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard self != nil else { return }
            let presenceService: PresenceServiceProtocol = DIContainer.shared.resolve()
            presenceService.setUserStatus(online: true)
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        let presenceService: PresenceServiceProtocol = DIContainer.shared.resolve()
        presenceService.setUserStatus(online: false)
    }


}

