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
    
    private let queue = DispatchQueue(label: "ProfileServiceQueue", attributes: .concurrent)
    
    private init() {}
    
    private func parse(data: Data) -> Profile? {
        do {
            let userProfile = try JSONDecoder().decode(ProfileResult.self, from: data)
            let profile = Profile(userProfile: userProfile)
            return profile
        } catch {
            print("Error parsing profile data: \(NetworkError.emptyData)")
            return nil
        }
    }
}

extension ProfileService: ProfileServiceProtocol {
    
    func request(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print(NetworkError.invalidURLString)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, any Error>) -> Void) {
        
        queue.async {
            guard let request = self.request(token: token) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.unableToConstructURL))
                }
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self else { return }
                
                let fulfillCompletionOnTheMainThread: (Result<Profile, Error>) -> Void = { result in
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
                
                if let error = error {
                    fulfillCompletionOnTheMainThread(.failure(error))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.unknownError))
                    return
                }
                
                if response.statusCode == 200 {
                    guard let data = data, let token = self.parse(data: data) else {
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.emptyData))
                        return
                    }
                    fulfillCompletionOnTheMainThread(.success(token))
                } else {
                    let error = NetworkErrorHandler.handleErrorResponse(statusCode: response.statusCode)
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            }
            task.resume()
        }
    }
}
