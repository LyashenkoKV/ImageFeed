//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 04.06.2024.
//

import Foundation

protocol OAuth2ServiceProtocol {
    func makeOAuthTokenRequest(code: String) -> URLRequest
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void)
}

final class OAuth2Service: OAuth2ServiceProtocol {
    static let shared = OAuth2Service()
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
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
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters, options: []) else {
            fatalError(NetworkError.unableToConstructURL.localizedDescription)
        }

        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
            
        let fulfillCompletionOnTheMainThread: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let request = makeOAuthTokenRequest(code: code)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let response = response as? HTTPURLResponse {
                print("response \(response)")
                switch response.statusCode {
                case 200..<300:
                    if let data {
                        guard let token = parseAndStoreToken(data: data) else {
                            fulfillCompletionOnTheMainThread(.failure(NetworkError.emptyData))
                            return
                        }
                        fulfillCompletionOnTheMainThread(.success(token))
                    } else {
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.emptyData))
                    }
                case 400:
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.invalidURLString))
                case 401:
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.errorFetchingAccessToken))
                case 403:
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.unauthorized))
                case 404:
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.notFound))
                case 422:
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.unknownError))
                case 500, 503:
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.serviceUnavailable))
                default:
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.unknownError))
                }
            } else if let error = error {
                if let nsError = error as NSError?, nsError.code == NSURLErrorTimedOut {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.requestTimedOut))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.noInternetConnection))
                }
            }
        }
        task.resume()
    }
    
    private func parseAndStoreToken(data: Data) -> String? {
        do {
            let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            let accessToken = tokenResponse.accessToken
            self.oAuth2TokenStorage.token = accessToken
            print("Токен доступа сохранен: \(accessToken)")
            return accessToken
        } catch {
            let error = NetworkErrorHandler.errorMessage(from: error)
            print("Ошибка анализа ответа токена: \(error)")
            return nil
        }
    }
}
