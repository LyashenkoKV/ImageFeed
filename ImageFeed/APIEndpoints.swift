//
//  APIEndpoints.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 19.07.2024.
//

import Foundation

enum APIEndpoints {
    enum OAuth {
        static let token = "https://unsplash.com/oauth/token"
    }

    enum Profile {
        static func profile(username: String) -> String {
            return "https://api.unsplash.com/users/\(username)"
        }
        static let me = "https://api.unsplash.com/me"
    }
    
    enum Photos {
        static let photos = "https://api.unsplash.com/photos"
    }
}
