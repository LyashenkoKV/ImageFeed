//
//  MockProfileImageService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 22.07.2024.
//

import Foundation

final class MockProfileImageService: ProfileImageServiceProtocol {

    func fetchProfileImageURL(username: String, token: String, completion: @escaping (Result<String, Error>) -> Void) {
        let mockURL = "https://mockurl.com"
        completion(.success(mockURL))
    }
}
