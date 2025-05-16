//
//  NetworkType.swift
//  Test
//
//  Created by Abdulkadir Oruç on 16.05.2025.
//

import Alamofire

enum NetworkType {
    case get
    case post
    case put
    case delete

    func toAlamofire() -> HTTPMethod {
        switch self {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .delete: return .delete
        }
    }
}
