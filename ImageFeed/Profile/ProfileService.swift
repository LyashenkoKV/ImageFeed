//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 14.06.2024.
//

import UIKit

protocol ProfileServiceProtocol {
    func request(token: String) -> URLRequest?
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
}

final class ProfileService {
    static let shared = ProfileService()
    
    
    private init() {}
}

extension ProfileService: ProfileServiceProtocol {
    
    func request(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print(NetworkError.invalidURLString)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, any Error>) -> Void) {
        DispatchQueue.main.async {
            
        }
    }
}
