//
//  StatisticsModuleBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 19.05.2025.
//


struct StatisticsModuleBuilder {
    static func build() -> StatisticsViewController {
        return StatisticsViewController(viewModel: StatisticsViewModel(service: TimerService()))
    }
}
