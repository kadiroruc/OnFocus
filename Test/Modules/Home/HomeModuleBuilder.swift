//
//  HomeModuleBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

struct HomeModuleBuilder {
    static func build() -> HomeViewController {
        return HomeViewController(viewModel: HomeViewModel(timerService: TimerService()))
    }
}
