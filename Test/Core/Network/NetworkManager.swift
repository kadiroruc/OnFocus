//
//  NetworkManager.swift
//  Test
//
//  Created by Abdulkadir Oruç on 18.06.2025.
//

import Foundation

protocol NetworkManager {
    func sendRequest<T: Decodable>(_ endpoint: EndpointProtocol, responseType: T.Type) async throws -> T
}

class URLSessionNetworkManager: NetworkManager {
    static let shared = URLSessionNetworkManager()
    private init() {}
    
    enum NetworkError: Error {
        case invalidURL
        case requestFailed
        case invalidResponse(statusCode: Int)
        case decodingError
    }
    
    func sendRequest<T: Decodable>(_ endpoint: EndpointProtocol, responseType: T.Type) async throws -> T {
        let request = endpoint.makeUrlRequest()
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw NetworkError.decodingError
            }
            
        } catch {
            throw NetworkError.requestFailed
        }
    }
}
