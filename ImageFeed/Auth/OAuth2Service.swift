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
            print(NetworkError.unableToConstructURL.localizedDescription)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components?.percentEncodedQuery?.data(using: .utf8)
        
        return request
    }
    
    func parse(data: Data) -> OAuthTokenResponseBody? {
        do {
            let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            self.oAuth2TokenStorage.token = tokenResponse.accessToken
            print("Access token saved: \(tokenResponse.accessToken)")
            return tokenResponse
        } catch {
            print("Token parsing error: \(NetworkError.errorFetchingAccessToken)")
            return nil
        }
    }
    
    func fetchOAuthToken(code: String, 
                         completion: @escaping (Result<String, Error>) -> Void) {
        serialQueue.async { [weak self] in
            guard let self = self else { return }
            
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
            
            self.fetch(parameters: parameters, 
                       method: "POST",
                       url: "https://unsplash.com/oauth/token") { (result: Result<OAuthTokenResponseBody, Error>) in
                self.serialQueue.async {
                    let completions = self.activeRequests.removeValue(forKey: code) ?? []
                    for completion in completions {
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let response):
                                completion(.success(response.accessToken))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                }
            }
        }
    }
}
