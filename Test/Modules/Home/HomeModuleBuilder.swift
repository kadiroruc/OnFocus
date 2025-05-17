//
//  HomeModuleBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

import UIKit

struct HomeModuleBuilder {
    static func build() -> UIViewController {
            
        return HomeViewController(viewModel: HomeViewModel())
    }
}
