//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 04.06.2024.
//

import Foundation

// MARK: - Protocol
protocol OAuth2ServiceProtocol {
    func makeOAuthTokenRequest(code: String) -> URLRequest?
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void)
}

// MARK: - Object
final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    private var currentTask: URLSessionDataTask?
    private var currentCode: String?
    
    private init() {}

    private func parseAndStoreToken(data: Data) -> String? {
        do {
            let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            let accessToken = tokenResponse.accessToken
            self.oAuth2TokenStorage.token = accessToken
            print("Access token saved: \(accessToken)")
            return accessToken
        } catch {
            print("Token parsing error: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - OAuth2ServiceProtocol
extension OAuth2Service: OAuth2ServiceProtocol {
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "unsplash.com"
        components.path = "/oauth/token"

        let bodyParameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]

        components.queryItems = bodyParameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components.url else {
            print(NetworkError.unableToConstructURL.localizedDescription)
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)

        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.async {
            if let currentCode = self.currentCode, currentCode == code, let currentTask = self.currentTask {
                currentTask.cancel()
            } else if let currentCode = self.currentCode, currentCode != code {
                completion(.failure(NetworkError.tooManyRequests))
                return
            }
            
            guard let request = self.makeOAuthTokenRequest(code: code) else {
                completion(.failure(NetworkError.unableToConstructURL))
                return
            }
            
            self.currentCode = code
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self else { return }
                
                DispatchQueue.main.async {
                    self.currentTask = nil
                    self.currentCode = nil
                }
                
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
                    guard let data = data, let token = self.parseAndStoreToken(data: data) else {
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.emptyData))
                        return
                    }
                    fulfillCompletionOnTheMainThread(.success(token))
                } else {
                    let error = NetworkErrorHandler.handleErrorResponse(statusCode: response.statusCode)
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            }
            
            self.currentTask = task
            task.resume()
        }
    }
}
