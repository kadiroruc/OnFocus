//
//  NetworkManager.swift
//  Test
//
//  Created by Abdulkadir Oruç on 16.05.2025.
//

import UIKit
import Alamofire

//MARK: - Protocol
protocol NetworkManaging {
    func request<T: Codable>(_ path: NetworkPath,
                             decodeTo type: T.Type,
                             completion: @escaping (Result<T, Error>) -> ())
    
    func upload<T: Codable>(_ path: NetworkPath,
                            decodeTo type: T.Type,
                            completion: @escaping (Result<T, Error>) -> ())
}
//MARK: - Class

final class AFNetworkManager: NetworkManaging {
    
    //JSON Data
    func request<T: Codable>(_ path: NetworkPath,
                             decodeTo type: T.Type,
                             completion: @escaping (Result<T, Error>) -> ()) {
        AF.request(path.urlString,
                   method: path.method,
                   parameters: path.parameters,
                   encoding: path.encoding)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let result = try JSONDecoder().decode(type.self, from: data)
                        completion(.success(result))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    //Multipart Data
    func upload<T: Codable>(_ path: NetworkPath,
                            decodeTo type: T.Type,
                            completion: @escaping (Result<T, Error>) -> ()) {
        
        guard let multipartFormDataClosure = path.multipartFormData else {
            completion(.failure(NSError(domain: "MultipartError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No multipart form data provided."])))
            return
        }
        
        AF.upload(multipartFormData: { multipart in
            multipartFormDataClosure(multipart)
        }, to: path.urlString, method: path.method)
        .validate()
        .responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(type.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
