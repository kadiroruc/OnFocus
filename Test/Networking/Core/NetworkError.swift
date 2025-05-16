//
//  NetworkError.swift
//  Test
//
//  Created by Abdulkadir Oruç on 16.05.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case serverError(String)
    case unknown
}

