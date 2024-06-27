//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 17.06.2024.
//

import UIKit

// MARK: - Object
final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let serialQueue = DispatchQueue(label: "ProfileImageService.serialQueue")
    private(set) var avatarURL: String?
    
    private init() {}
}

// MARK: - NetworkService
extension ProfileImageService: NetworkService {
    func makeRequest(parameters: [String: String], 
                     method: String,
                     url: String) -> URLRequest? {
        guard let url = URL(string: url) else {
            Logger.shared.log(.error, message: "Неверная строка URL: \(url)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(parameters["token"] ?? "")", 
                         forHTTPHeaderField: "Authorization")
        
        Logger.shared.log(.debug, message: "Запрос создан: \(request)")
        
        return request
    }
    
    func parse(data: Data) -> UserResult? {
        do {
            let userResult = try JSONDecoder().decode(UserResult.self, from: data)
            Logger.shared.log(.debug, message: "User result успешно обработаны")
            return userResult
        } catch {
            Logger.shared.log(.error, message: "Ошибка парсинга User result: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchProfileImageURL(username: String, 
                              token: String,
                              completion: @escaping (Result<String, Error>) -> Void) {
        serialQueue.async {
            self.fetch(parameters: ["username": username, "token": token], 
                       method: "GET",
                       url: APIEndpoints.Profile.profile(username: username)) { (result: Result<UserResult, Error>) in
                switch result {
                case .success(let userResult):
                    if let imageURL = userResult.profileImage {
                        let profileImageURL = imageURL.large
                        self.avatarURL = profileImageURL
                        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification,
                                                        object: self,
                                                        userInfo: ["URL": profileImageURL])
                        DispatchQueue.main.async {
                            Logger.shared.log(.debug, message: "URL изображения профиля успешно получен", metadata: ["URL": profileImageURL])
                            completion(.success(profileImageURL))
                        }
                    } else {
                        DispatchQueue.main.async {
                            Logger.shared.log(.debug, message: "URL-адрес изображения профиля не найден")
                            completion(.success(""))
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        Logger.shared.log(.error, message: "Не удалось получить URL изображения профиля", metadata: ["error": error.localizedDescription])
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
