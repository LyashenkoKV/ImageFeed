//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 15.07.2024.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    
    let configuration: AuthConfiguration

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest? {
        guard let urlString = authURL(), let url = URL(string: urlString) else {
            Logger.shared.log(.error,
                              message: "AuthService: Неверная строка URL",
                              metadata: ["❌": ""])
            return nil
        }
        
        let request = URLRequest(url: url)
        
        Logger.shared.log(.debug,
                          message: "AuthService: Запрос создан:",
                          metadata: ["✅": "\(request)"])
        
        return URLRequest(url: url)
    }
    
    private func authURL() -> String? {
        var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        return urlComponents?.url?.absoluteString
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == Constants.authRedirectPath,
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
