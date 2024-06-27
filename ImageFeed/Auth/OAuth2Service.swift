//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 04.06.2024.
//

import Foundation
// MARK: - Object
final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    private let serialQueue = DispatchQueue(label: "OAuth2Service.serialQueue")
    private var activeRequests: [String: [(Result<String, Error>) -> Void]] = [:]
    
    private init() {}
}

// MARK: - NetworkService
extension OAuth2Service: NetworkService {
    func makeRequest(parameters: [String: String], 
                     method: String,
                     url: String) -> URLRequest? {
        var components = URLComponents(string: url)
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = components?.url else {
            Logger.shared.log(.error, message: "Невозможно создать URL с параметрами: \(parameters)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components?.percentEncodedQuery?.data(using: .utf8)
        
        Logger.shared.log(.debug, message: "Запрос на создание: \(request)")
        
        return request
    }
    
    func parse(data: Data) -> OAuthTokenResponseBody? {
        do {
            let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            self.oAuth2TokenStorage.token = tokenResponse.accessToken
            Logger.shared.log(.debug, message: "Access token сохранен", metadata: ["token": tokenResponse.accessToken])
            return tokenResponse
        } catch {
            Logger.shared.log(.error, message: "Ошибка обработки токена: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchOAuthToken(code: String, 
                         completion: @escaping (Result<String, Error>) -> Void) {
        serialQueue.async {
            
            if self.activeRequests[code] != nil {
                self.activeRequests[code]?.append(completion)
                return
            } else {
                self.activeRequests[code] = [completion]
            }
            
            let parameters = [
                "client_id": Constants.accessKey,
                "client_secret": Constants.secretKey,
                "redirect_uri": Constants.redirectURI,
                "code": code,
                "grant_type": "authorization_code"
            ]
            
            Logger.shared.log(.debug, message: "Получение токена OAuth с кодом: \(code)")
            
            self.fetch(parameters: parameters, 
                       method: "POST",
                       url: APIEndpoints.OAuth.token) { (result: Result<OAuthTokenResponseBody, Error>) in
                self.serialQueue.async {
                    let completions = self.activeRequests.removeValue(forKey: code) ?? []
                    for completion in completions {
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let response):
                                Logger.shared.log(.debug, message: "Токен OAuth успешно получен", metadata: ["token": response.accessToken])
                                completion(.success(response.accessToken))
                            case .failure(let error):
                                Logger.shared.log(.error, message: "Не удалось получить токен OAuth", metadata: ["error": error.localizedDescription])
                                completion(.failure(error))
                            }
                        }
                    }
                }
            }
        }
    }
}
