//
//  NetworkConstants.swift
//  Test
//
//  Created by Abdulkadir Oruç on 16.05.2025.
//

import Foundation

struct NetworkConstants {
    static let baseURL = "https://api.imgbb.com/1"
    static var imgBBApiKey: String {
        guard
            let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = plist["IMGBBAPIKey"] as? String
        else {
            fatalError("API Key not found. Make sure Config.plist exists and is configured.")
        }
        return key
    }
}

