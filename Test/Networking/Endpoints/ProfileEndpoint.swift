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
    case fetchImage(imageId: String)
    
    var urlString: String {
        switch self {
        case .uploadImage:
            return "\(NetworkConstants.baseURL)upload?key=\(NetworkConstants.imgBBApiKey)"
        case .fetchImage(let imageId):
            return "\(NetworkConstants.baseURL)images/\(imageId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .uploadImage:
            return .post
        case .fetchImage:
            return .get
        }
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        switch self {
        case .uploadImage(let data):
            return { multipart in
                multipart.append(data, withName: "image", fileName: "profile.jpg", mimeType: "image/jpeg")
            }
        case .fetchImage:
            return nil
        }
    }
    
    var parameters: [String : Any]? {
        return nil // If you want to add extra parameters like name, expiration etc.
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .uploadImage:
            return URLEncoding.default
        case .fetchImage:
            return URLEncoding.default
        }
    }
}
