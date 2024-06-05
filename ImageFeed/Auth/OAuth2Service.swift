//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 04.06.2024.
//

import Foundation

protocol OAuth2ServiceProtocol {
    func makeOAuthTokenRequest(code: String) -> URLRequest
    func fetchOAuthToken(code: String, completion: @escaping (Result<Data, Error>) -> Void)
}

final class OAuth2Service: OAuth2ServiceProtocol {
    static let shared = OAuth2Service()
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "unsplash.com"
        components.path = "/oauth/token"

        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let url = components.url else {
            fatalError(NetworkError.unableToConstructURL.localizedDescription)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let request = makeOAuthTokenRequest(code: code)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    if let data {
                        fulfillCompletionOnTheMainThread(.success(data))
                        OAuth2TokenStorage.shared.token = String(decoding: data, as: UTF8.self)
                    } else {
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.emptyData))
                    }
                case 400:
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.invalidURLString))
                case 401:
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.errorFetchingAccessToken))
                case 403:
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.unauthorized))
                case 422:
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.unknownError))
                case 500..<600:
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.serviceUnavailable))
                default:
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.unknownError))
                }
            } else if let error {
                if let nsError = error as NSError?, nsError.code == NSURLErrorTimedOut {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.requestTimedOut))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.noInternetConnection))
                }
            }
        }
        task.resume()
    }
}
