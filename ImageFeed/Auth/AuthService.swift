//
//  AuthService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 04.06.2024.
//


import Foundation
import WebKit

protocol AuthServiceDelegate: AnyObject {
    func authService(_ authService: AuthService, didAuthenticateWithCode code: String)
    func authServiceDidCancel(_ authService: AuthService)
    func authService(_ authService: AuthService, didFailWithError error: Error)
}

final class AuthService: NSObject {
    weak var delegate: AuthServiceDelegate?
    private let webView: WKWebView

    init(webView: WKWebView) {
        self.webView = webView
        super.init()
        self.webView.navigationDelegate = self
    }
    
    private func authURL() -> String? {
        if var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) {
            
            urlComponents.queryItems = [
                URLQueryItem(name: "client_id", value: Constants.accessKey),
                URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
                URLQueryItem(name: "response_type", value: "code"),
                URLQueryItem(name: "scope", value: Constants.accessScope)
            ]
            
            return urlComponents.url?.absoluteString
        }
        return ""
    }
    
    func loadAuthView() {
        guard let urlString = authURL(), let url = URL(string: urlString) else {
            print(NetworkError.invalidURLString)
            return
        }
        
        let request = URLRequest(url: url)
        DispatchQueue.main.async {
            self.webView.load(request)
            print("Loading request: \(request)")
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }

    private func showErrorAlert(with message: String) {
        delegate?.authService(self, didFailWithError: NSError(domain: "", 
                                                              code: 0,
                                                              userInfo: [NSLocalizedDescriptionKey: message]))
    }
}

extension AuthService: WKNavigationDelegate {
    func webView(_ webView: WKWebView, 
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let code = code(from: navigationAction) {
            OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let token):
                    self.delegate?.authService(self, didAuthenticateWithCode: code)
                    print("Токен получен")
                    print("\(token)") // ❌
                case .failure(let error):
                    self.showErrorAlert(with: NetworkErrorHandler.errorMessage(from: error))
                    print(NetworkError.errorFetchingAccessToken)
                }
            }
            decisionHandler(.cancel)
            return
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showErrorAlert(with: NetworkErrorHandler.errorMessage(from: error))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showErrorAlert(with: NetworkErrorHandler.errorMessage(from: error))
    }
}
