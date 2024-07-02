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
    
    func clearProfileImage() {
        avatarURL = nil
        Logger.shared.log(.debug,
                          message: "ProfileImageService: Изображение профиля успешно удалено",
                          metadata: ["❎": ""])
    }
}

// MARK: - NetworkService
extension ProfileImageService: NetworkService {
    func makeRequest(parameters: [String: String], 
                     method: String,
                     url: String) -> URLRequest? {
        guard let url = URL(string: url) else {
            Logger.shared.log(.error, 
                              message: "ProfileImageService: Неверная строка URL" ,
                              metadata: ["❌": url])
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(parameters["token"] ?? "")", 
                         forHTTPHeaderField: "Authorization")
        
        Logger.shared.log(.debug, 
                          message: "ProfileImageService: Запрос изображения профиля создан:",
                          metadata: ["✅": "\(request)"])
        
        return request
    }
    
    func parse(data: Data) -> UserResult? {
        do {
            let userResult = try JSONDecoder().decode(UserResult.self, from: data)
            Logger.shared.log(.debug, 
                              message: "ProfileImageService: Данные изображения профиля успешно обработаны",
                              metadata: ["✅": ""])
            return userResult
        } catch {
            let errorMessage = NetworkErrorHandler.errorMessage(from: error)
            Logger.shared.log(.error,
                              message: "ProfileImageService: Ошибка парсинга изображения профиля",
                              metadata: ["❌": errorMessage])
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
                            Logger.shared.log(.debug,
                                              message: "ProfileImageService: URL изображения профиля успешно получены",
                                              metadata: ["✅ URL": profileImageURL])
                            completion(.success(profileImageURL))
                        }
                    } else {
                        DispatchQueue.main.async {
                            Logger.shared.log(.debug, 
                                              message: "ProfileImageService: URL-адрес изображения профиля не найден",
                                              metadata: ["❗️": ""])
                            completion(.success(""))
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        let errorMessage = NetworkErrorHandler.errorMessage(from: error)
                        Logger.shared.log(.error,
                                          message: "ProfileImageService: Не удалось получить URL изображения профиля",
                                          metadata: ["❌": errorMessage])
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
