//
//  UploadProfileImageResponse.swift
//  Test
//
//  Created by Abdulkadir Oruç on 16.05.2025.
//

import Foundation

struct UploadResponse: Codable {
    let data: UploadImageData
    let success: Bool
    let status: Int
}

struct UploadImageData: Codable {
    let id: String
    let url: String
    let display_url: String
    let delete_url: String
    let image: UploadImageDetail
    let thumb: UploadImageDetail
    let medium: UploadImageDetail
}

struct UploadImageDetail: Codable {
    let filename: String
    let name: String
    let mime: String
    let `extension`: String
    let url: String
}
