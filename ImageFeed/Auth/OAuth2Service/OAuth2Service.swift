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
    
    private let serialQueue = DispatchQueue(label: "OAuth2Service.serialQueue")
    private var activeRequests: [String: [(Result<String, Error>) -> Void]] = [:]
    private let oAuth2RequestHelper = OAuth2RequestHelper()
    private let oAuth2ParserHelper = OAuth2ParserHelper()
    
    private init() {}
}

// MARK: - NetworkService
extension OAuth2Service: NetworkService {
    func makeRequest(parameters: [String: String], method: String, url: String) -> URLRequest? {
        oAuth2RequestHelper.makeRequest(parameters: parameters, method: method, url: url)
    }
    
    func parse(data: Data) -> OAuthTokenResponseBody? {
        oAuth2ParserHelper.parse(data: data)
    }
    
    private func createOAuthParameters(with code: String) -> [String: String] {
        [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        serialQueue.async { [weak self] in
            guard let self else { return }

            if self.isActiveRequest(for: code, completion: completion) {
                return
            }

            let parameters = createOAuthParameters(with: code)
            
            Logger.shared.log(.debug,
                              message: "OAuth2Service: Получение токена OAuth с кодом:",
                              metadata: ["✅": code])
            
            self.performOAuthRequest(with: parameters, for: code)
        }
    }

    private func isActiveRequest(for code: String, completion: @escaping (Result<String, Error>) -> Void) -> Bool {
        if activeRequests[code] != nil {
            activeRequests[code]?.append(completion)
            return true
        } else {
            activeRequests[code] = [completion]
            return false
        }
    }

    private func performOAuthRequest(with parameters: [String: String], for code: String) {
        fetch(parameters: parameters, method: "POST", url: APIEndpoints.OAuth.token) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }

            self.handleOAuthResponse(result, for: code)
        }
    }

    private func handleOAuthResponse(_ result: Result<OAuthTokenResponseBody, Error>, for code: String) {
        serialQueue.async { [weak self] in
            guard let self else { return }
            
            let completions = self.activeRequests.removeValue(forKey: code) ?? []
            for completion in completions {
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        Logger.shared.log(.debug,
                                          message: "OAuth2Service: Токен OAuth успешно получен",
                                          metadata: ["✅": response.accessToken])
                        completion(.success(response.accessToken))
                    case .failure(let error):
                        let errorMessage = NetworkErrorHandler.errorMessage(from: error)
                        Logger.shared.log(.error,
                                          message: "OAuth2Service: Не удалось получить токен OAuth",
                                          metadata: ["❌": errorMessage])
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
