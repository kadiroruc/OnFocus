//
//  ProductEndpoint.swift
//  Test
//
//  Created by Abdulkadir Oruç on 16.05.2025.
//

import Foundation
import Alamofire

protocol NetworkPath {
    var urlString: String { get }
    var method: HTTPMethod { get }
    var multipartFormData: ((MultipartFormData) -> Void)? { get }
    var parameters: [String: Any]? { get }
    var encoding: ParameterEncoding { get }
}

enum ProfileEndpoint: NetworkPath {
    case uploadImage(data: Data)
    
    var urlString: String {
        switch self {
        case .uploadImage:
            return "\(NetworkConstants.baseURL)upload?key=\(NetworkConstants.apiKey)"
        }
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        switch self {
        case .uploadImage(let data):
            return { multipart in
                multipart.append(data, withName: "image", fileName: "profile.jpg", mimeType: "image/jpeg")
            }
        }
    }
    
    var parameters: [String : Any]? {
        return nil // Ekstra parametre eklemek istersen buraya (örneğin "name" veya "expiration")
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
}
