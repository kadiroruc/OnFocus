//
//  TabBarBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

import UIKit

struct TabBarModuleBuilder {
    static func build() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let homeNav = HomeModuleBuilder.build()
        homeNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: Constants.Icons.clockArrowCirclepath), tag: 0)
        
        let profileVC = ProfileViewController()
        profileVC.title = "Profile"
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: Constants.Icons.person), tag: 1)
        profileNav.tabBarItem.selectedImage = UIImage(systemName: Constants.Icons.personFill)
        
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.title = "Statistics"
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)
        statisticsNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: Constants.Icons.chartLineUptrendXyaxis), tag: 2)
        
        let notificationsVC = NotificationsViewController()
        notificationsVC.title = "Notifications"
        let notificationsNav = UINavigationController(rootViewController: notificationsVC)
        notificationsNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: Constants.Icons.bell), tag: 2)
        notificationsNav.tabBarItem.selectedImage = UIImage(systemName: Constants.Icons.bellFill)
        
        let leaderboardVC = LeaderboardViewController()
        leaderboardVC.title = "Leaderboard"
        let leaderboardNav = UINavigationController(rootViewController: leaderboardVC)
        leaderboardNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: Constants.Icons.person2), tag: 2)
        leaderboardNav.tabBarItem.selectedImage = UIImage(systemName: Constants.Icons.person2Fill)
        
        //let profileSearch = ProfileSearchViewController()
        
        
        // TabBarController'a navları ekle
        tabBarController.viewControllers = [leaderboardNav,statisticsNav,homeNav,notificationsNav, profileNav]
        tabBarController.tabBar.tintColor = .black
        tabBarController.selectedIndex = 2
        
        return tabBarController
    }
}
