//
//  ProfileImageEndpoint.swift
//  Test
//
//  Created by Abdulkadir Oruç on 18.06.2025.
//

import Foundation

enum ImageUploadEndpoint {
    case uploadImage(data: Data)
}

extension ImageUploadEndpoint: EndpointProtocol {
    
    var baseURL: String {
        return NetworkConstants.baseURL // örn: "https://api.imgbb.com/1/"
    }
    
    var path: String {
        switch self {
        case .uploadImage:
            return "upload"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .uploadImage:
            return .POST
        }
    }
    
    var queryParams: [String : Any]? {
        switch self {
        case .uploadImage:
            return ["key": NetworkConstants.imgBBApiKey]
        }
    }
    
    var header: [String : String]? {
        // Multipart form-data Content-Type makeUrlRequest'te otomatik eklenir, eklemeye gerek yok
        return nil
    }
    
    
    var multipartFormData: [(name: String, filename: String, mimeType: String, data: Data)]? {
        switch self {
        case .uploadImage(let data):
            return [("image", "profile.jpg", "image/jpeg", data)]
        }
    }
}
