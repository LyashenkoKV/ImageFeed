//
//  MockProfileService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 22.07.2024.
//

import Foundation

final class MockProfileService: ProfileServiceProtocol {
    var isProfileLoaded: Bool = false
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        let mockProfile = Profile(userProfile: ProfileResult(userName: "@johndoe", firstName: "John", lastName: "Doe", bio: "Developer"))
        completion(.success(mockProfile))
    }
}
