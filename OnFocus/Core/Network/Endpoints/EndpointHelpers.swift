//
//  EndpointHelpers.swift
//  Test
//
//  Created by Abdulkadir Oruç on 18.06.2025.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

//All endpoint group will confirm this protocol
protocol EndpointProtocol {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var header: [String: String]? { get }
    var queryParams: [String: Any]? { get }
    var multipartFormData: [(name: String, filename: String, mimeType: String, data: Data)]? { get }
}

extension EndpointProtocol {
    
    func makeUrlRequest() -> URLRequest {
        guard var components = URLComponents(string: baseURL) else { fatalError("Invalid base URL") }
        
        // Add path
        components.path += "/\(path)"
        
        // QUERY PARAMS
        if let queryParams = queryParams {
            var queryItems: [URLQueryItem] = []
            for (key, value) in queryParams {
                queryItems.append(URLQueryItem(name: key, value: String(describing: value)))
            }
            components.queryItems = queryItems
        }

        // REQUEST
        var request = URLRequest(url: components.url!)
        request.httpMethod = method.rawValue

        // HEADERS
        if let header = header {
            for (key, value) in header {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        // MULTIPART
        if let multipartFormData = multipartFormData {
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            var body = Data()

            for formData in multipartFormData {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(formData.name)\"; filename=\"\(formData.filename)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: \(formData.mimeType)\r\n\r\n".data(using: .utf8)!)
                body.append(formData.data)
                body.append("\r\n".data(using: .utf8)!)
            }

            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body
        }

        return request
    }
    
}
