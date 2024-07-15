//
//  AuthService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 04.06.2024.
//


import Foundation
import WebKit
// MARK: - protocols
protocol AuthServiceDelegate: AnyObject {
    func authService(_ authService: AuthService, didAuthenticateWithCode code: String)
    func authServiceDidCancel(_ authService: AuthService)
    func authService(_ authService: AuthService, didFailWithError error: Error)
    func authService(_ authService: AuthService, didUpdateProgressValue newValue: Double)
}

protocol AuthServiceProtocol: AnyObject {
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

// MARK: - object
final class AuthService: NSObject {
    weak var delegate: AuthServiceDelegate?
    private let webView: WKWebView
    var authHelper: AuthHelperProtocol

    init(webView: WKWebView, authHelper: AuthHelperProtocol) {
        self.webView = webView
        self.authHelper = authHelper
        super.init()
        self.webView.navigationDelegate = self
    }
    
    private func showErrorAlert(with message: String) {
        delegate?.authService(self, didFailWithError: NSError(domain: "",
                                                              code: 0,
                                                              userInfo: [NSLocalizedDescriptionKey: message]))
    }
}

// MARK: - WKNavigationDelegate
extension AuthService: WKNavigationDelegate {
    func webView(_ webView: WKWebView, 
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            Logger.shared.log(.error,
                              message: "AuthService: Ошибка получения кода",
                              metadata: ["❌": ""])
            return
        }
        if let code = code(from: url) {
            self.delegate?.authService(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let errorMessage = NetworkErrorHandler.errorMessage(from: error)
        showErrorAlert(with: errorMessage)
        Logger.shared.log(.error,
                          message: "AuthService: Ошибка при загрузке данных WebView",
                          metadata: ["❌": errorMessage])
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.shared.log(.debug,
                          message: "AuthService: Загрузка завершена:",
                          metadata: ["✅": ""])
        // Обновляем прогресс, когда загрузка завершена
        delegate?.authService(self, didUpdateProgressValue: 1.0)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Обновляем прогресс на начало загрузки
        delegate?.authService(self, didUpdateProgressValue: webView.estimatedProgress)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Обновляем прогресс при начале навигации
        delegate?.authService(self, didUpdateProgressValue: webView.estimatedProgress)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectFor navigation: WKNavigation!) {
        // Обновляем прогресс при получении редиректа
        delegate?.authService(self, didUpdateProgressValue: webView.estimatedProgress)
    }
}

// MARK: - WebViewViewControllerProtocol
extension AuthService: WebViewViewControllerProtocol {
    
    func loadAuthView() {
        guard let request = authHelper.authRequest() else {
            delegate?.authService(self, didFailWithError: NetworkError.invalidURLString)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            self.webView.load(request)
        }
    }
}

// MARK: - AuthServiceProtocol
extension AuthService: AuthServiceProtocol {
    func didUpdateProgressValue(_ newValue: Double) {
        delegate?.authService(self, didUpdateProgressValue: newValue)
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
