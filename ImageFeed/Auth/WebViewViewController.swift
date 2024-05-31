//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 31.05.2024.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {
    
    weak var delegate: WebViewViewControllerDelegate?
    private let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        webView.navigationDelegate = self
        configureBackButton()
        setupUI()
        setupConstraints()
        loadAuthView()
    }
    
    private func setupUI() {
        configureWebView()
        view.addSubview(webView)
    }
    
    private func configureBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), 
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonPressed))
        backButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func configureWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc private func backButtonPressed() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    func loadAuthView()  {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
            print("Error: Invalid URL string")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Error: Unable to construct URL from URLComponents")
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
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            //TODO: process code
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
