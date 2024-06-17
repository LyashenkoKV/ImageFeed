//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 17.06.2024.
//

import UIKit
// MARK: - protocol
protocol ProfileImageServiceProtocol {
    func request(username: String, token: String) -> URLRequest?
    func fetchProfileImageURL(username: String, token: String, _ completion: @escaping (Result<String, Error>) -> Void)
}
// MARK: - object
final class ProfileImageService {
    static let shared = ProfileImageService()
    
    private(set) var avatarURL: String?
    private let queue = DispatchQueue(label: "ProfileImageServiceQueue", attributes: .concurrent)
    private var currentTask: URLSessionDataTask?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    init() {}
    
    private func parse(data: Data) -> String? {
        do {
            let userResult = try JSONDecoder().decode(UserResult.self, from: data)
            self.avatarURL = userResult.profileImage.small
            return self.avatarURL
        } catch {
            print("Error parsing profile data: \(NetworkError.emptyData)")
            return nil
        }
    }
}
// MARK: - ProfileImageServiceProtocol
extension ProfileImageService: ProfileImageServiceProtocol {
    func request(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print(NetworkError.invalidURLString)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchProfileImageURL(username: String, token: String, _ completion: @escaping (Result<String, any Error>) -> Void) {
        queue.async() { [weak self] in
            guard let self else { return }
            
            self.currentTask?.cancel()
            
            guard let request = self.request(username: username, token: token) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.unableToConstructURL))
                }
                return
            }
            
            self.currentTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self else { return }
                
                let fulfillCompletionOnTheMainThread: (Result<String, Error>) -> Void = { result in
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
                    guard let data = data, let profileImageURL = self.parse(data: data) else {
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.emptyData))
                        return
                    }
                    fulfillCompletionOnTheMainThread(.success(profileImageURL))
                    NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, 
                                                    object: self,
                                                    userInfo: ["URL": profileImageURL])
                } else {
                    let error = NetworkErrorHandler.handleErrorResponse(statusCode: response.statusCode)
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            }
            self.currentTask?.resume()
        }
    }
}
