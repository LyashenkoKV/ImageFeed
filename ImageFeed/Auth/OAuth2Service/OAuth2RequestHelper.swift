//
//  OAuth2RequestHelper.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 18.07.2024.
//

import Foundation

// MARK: - Protocol
protocol OAuth2RequestHelperProtocol {
    func makeRequest(parameters: [String: String], method: String, url: String) -> URLRequest?
}

// MARK: - Object
final class OAuth2RequestHelper: OAuth2RequestHelperProtocol {
    func makeRequest(parameters: [String: String], method: String, url: String) -> URLRequest? {
        var components = URLComponents(string: url)
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = components?.url else {
            Logger.shared.log(.error,
                              message: "OAuth2RequestHelper: Невозможно создать URL с параметрами:",
                              metadata: ["❌": "\(parameters)"])
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components?.percentEncodedQuery?.data(using: .utf8)
        
        Logger.shared.log(.debug,
                          message: "OAuth2RequestHelper: Запрос на создание:",
                          metadata: ["✅": "\(request)"])
        
        return request
    }
}


