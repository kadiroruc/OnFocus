//
//  TabBarBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

import UIKit

struct MainTabBarBuilder {
    static func makeTabBar(using container: DIContainer) -> UITabBarController {
        let tabBarController = UITabBarController()

        let leaderboardVC: LeaderboardViewController = container.resolve()
        leaderboardVC.title = L10n.TabBar.leaderboardTitle
        let leaderboardNav = UINavigationController(rootViewController: leaderboardVC)
        leaderboardNav.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: Constants.Icons.person2),
            selectedImage: UIImage(systemName: Constants.Icons.person2Fill)
        )

        let statisticsVC: StatisticsViewController = container.resolve()
        statisticsVC.title = L10n.TabBar.statisticsTitle
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)
        statisticsNav.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: Constants.Icons.chartLineUptrendXyaxis),
            tag: 1
        )

        let homeVC: HomeViewController = container.resolve()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.navigationBar.tintColor = UIColor(hex: Constants.Colors.darkGray)
        homeNav.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: Constants.Icons.clockArrowCirclepath),
            tag: 2
        )

        let notificationsVC: NotificationsViewController = container.resolve()
        notificationsVC.title = L10n.TabBar.notificationsTitle
        let notificationsNav = UINavigationController(rootViewController: notificationsVC)
        notificationsNav.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: Constants.Icons.bell),
            selectedImage: UIImage(systemName: Constants.Icons.bellFill)
        )

        let profileVC: ProfileViewController = container.resolve()
        profileVC.title = L10n.TabBar.profileTitle
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: Constants.Icons.person),
            selectedImage: UIImage(systemName: Constants.Icons.personFill)
        )

        tabBarController.viewControllers = [
            leaderboardNav,
            statisticsNav,
            homeNav,
            notificationsNav,
            profileNav
        ]
        tabBarController.tabBar.tintColor = .black
        tabBarController.selectedIndex = 2

        return tabBarController
    }
}
