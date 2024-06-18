//
//  UserResult.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 17.06.2024.
//

import Foundation

struct UserResult: Decodable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Decodable {
    let large: String
}
