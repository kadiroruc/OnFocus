//
//  HomeModuleBuilder.swift
//  Test
//
//  Created by Abdulkadir Oruç on 15.05.2025.
//

import UIKit

struct HomeModuleBuilder {
    static func build() -> UINavigationController {
        let homeNav = UINavigationController(rootViewController: HomeViewController())
        
        return homeNav
    }
}
