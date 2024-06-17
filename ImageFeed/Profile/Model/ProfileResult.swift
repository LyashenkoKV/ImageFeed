//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 14.06.2024.
//

import Foundation

struct ProfileResult: Decodable {
    let userName: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let loginName: String
    let userName: String
    let name: String?
    let bio: String?
    
    init(userProfile: ProfileResult) {
        self.userName = userProfile.userName
        self.name = [userProfile.firstName, userProfile.lastName].compactMap { $0 }.joined(separator: " ")
        self.loginName = "@\(userProfile.userName)"
        self.bio = userProfile.bio
    }
}
