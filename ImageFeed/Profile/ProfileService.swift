//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 14.06.2024.
//

import UIKit

protocol ProfileServiceProtocol {
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
}

final class ProfileService {
    
}

extension ProfileService: ProfileServiceProtocol {
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, any Error>) -> Void) {
        
    }
}
