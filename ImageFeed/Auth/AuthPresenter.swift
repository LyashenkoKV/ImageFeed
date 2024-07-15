//
//  AuthService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 04.06.2024.


import Foundation
import WebKit

protocol AuthPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

class AuthPresenter: NSObject {
    weak var view: WebViewViewControllerProtocol?
    private let authHelper: AuthHelperProtocol
    private let webView: WKWebView

    init(viewController: WebViewViewControllerProtocol, authHelper: AuthHelperProtocol, webView: WKWebView) {
        self.view = viewController
        self.authHelper = authHelper
        self.webView = webView
        super.init()
        self.webView.navigationDelegate = self
    }
}

extension AuthPresenter: AuthPresenterProtocol {

    func viewDidLoad() {
        loadAuthView()
        didUpdateProgressValue(0)
    }
    
    private func loadAuthView() {
        guard let request = authHelper.authRequest() else {
            view?.didFailWithError(NetworkError.invalidURLString)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            self.webView.load(request)
        }
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)

        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }

    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}

extension AuthPresenter: WKNavigationDelegate {
    func webView(_ webView: WKWebView, 
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            
            let error = NetworkError.invalidURLString
            view?.didFailWithError(error)
            Logger.shared.log(.error,
                              message: "AuthService: Неверный URL",
                              metadata: ["❌": ""])
            return
        }
        if let code = code(from: url) {
            view?.didAuthenticateWithCode(code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let errorMessage = NetworkErrorHandler.errorMessage(from: error)
        
        let error = NetworkError.emptyData
        view?.didFailWithError(error)
        Logger.shared.log(.error,
                          message: "AuthService: Ошибка при загрузке данных WebView",
                          metadata: ["❌": errorMessage])
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.shared.log(.debug,
                          message: "AuthService: Загрузка завершена:",
                          metadata: ["✅": ""])
        didUpdateProgressValue(1.0)
    }
}
