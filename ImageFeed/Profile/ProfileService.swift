//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 14.06.2024.
//

import UIKit

final class ProfileService: NetworkService {
    
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    private let serialQueue = DispatchQueue(label: "ProfileService.serialQueue")
    
    private init() {}
    
    func makeRequest(parameters: [String: String], method: String, url: String) -> URLRequest? {
        guard let url = URL(string: url) else {
            print(NetworkError.invalidURLString)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(parameters["token"] ?? "")", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func parse(data: Data) -> Profile? {
        do {
            let userProfile = try JSONDecoder().decode(ProfileResult.self, from: data)
            return Profile(userProfile: userProfile)
        } catch {
            print("Error parsing profile data: \(NetworkError.emptyData)")
            return nil
        }
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        serialQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.fetch(parameters: ["token": token], method: "GET", url: "https://api.unsplash.com/me") { (result: Result<Profile, Error>) in
                switch result {
                case .success(let profile):
                    DispatchQueue.main.async {
                        self.profile = profile
                        completion(.success(profile))
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
