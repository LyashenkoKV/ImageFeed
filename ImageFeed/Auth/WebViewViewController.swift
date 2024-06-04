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
    private let progressView = UIProgressView()
    private var authService: AuthService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        configureBackButton()
        configureProgressView()
        setupUI()
        setupConstraints()
        authService = AuthService(webView: webView)
        authService.delegate = self
        authService.loadAuthView()
        updateProgress()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
        }
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func setupUI() {
        configureWebView()
        view.addSubview(progressView)
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
    
    private func configureProgressView() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .ypBlack
    }
    
    private func configureWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc private func backButtonPressed() {
        let alert = UIAlertController(title: "Выход из авторизации",
                                      message: "Вы уверены, что хотите покинуть страницу авторизации?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Выход", style: .destructive) { _ in
            self.delegate?.webViewViewControllerDidCancel(self)
        })
        present(alert, animated: true)
    }
    
    private func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

extension WebViewViewController: AuthServiceDelegate {
    func authService(_ authService: AuthService, didAuthenticateWithCode code: String) {
        delegate?.webViewViewController(self, didAuthenticateWithCode: code)
    }

    func authServiceDidCancel(_ authService: AuthService) {
        delegate?.webViewViewControllerDidCancel(self)
    }

    func authService(_ authService: AuthService, didFailWithError error: Error) {
        showErrorAlert(with: NetworkErrorHandler.errorMessage(from: error))
    }
}
