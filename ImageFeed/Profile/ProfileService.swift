//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 14.06.2024.
//

import UIKit

// MARK: - Object
final class ProfileService {
    
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    private let serialQueue = DispatchQueue(label: "ProfileService.serialQueue")
    
    private init() {}
}
// MARK: - NetworkService
extension ProfileService: NetworkService {
    func makeRequest(parameters: [String: String], method: String, url: String) -> URLRequest? {
        guard let url = URL(string: url) else {
            Logger.shared.log(.error, message: "Неверная строка URL: \(url)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(parameters["token"] ?? "")", forHTTPHeaderField: "Authorization")
        
        Logger.shared.log(.debug, message: "Запрос создан: \(request)")
        
        return request
    }
    
    func parse(data: Data) -> Profile? {
        do {
            let userProfile = try JSONDecoder().decode(ProfileResult.self, from: data)
            Logger.shared.log(.debug, message: "Данные профиля успешно обработаны")
            return Profile(userProfile: userProfile)
        } catch {
            Logger.shared.log(.error, message: "Ошибка парсинга: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        serialQueue.async {
            self.fetch(parameters: ["token": token], 
                       method: "GET",
                       url: APIEndpoints.Profile.me) { (result: Result<Profile, Error>) in
                switch result {
                case .success(let profile):
                    DispatchQueue.main.async {
                        self.profile = profile
                        Logger.shared.log(.debug, message: "Профиль успешно получен")
                        completion(.success(profile))
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        Logger.shared.log(.error, message: "Не удалось загрузить профиль", metadata: ["error": error.localizedDescription])
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
