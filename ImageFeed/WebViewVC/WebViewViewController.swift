//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 31.05.2024.
//


import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
    func webViewViewController(_ vc: WebViewViewController, didFailWithError error: Error)
}

protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: AuthPresenterProtocol? { get set }
    func loadAuthView(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
    func didAuthenticateWithCode(_ code: String)
    func didFailWithError(_ error: Error)
    func didCancel()
}

class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: AuthPresenterProtocol?
    
    private lazy var webView = WKWebView()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = .black
        progressView.progress = 0.0
        return progressView
    }()
    
    private lazy var backButton: UIBarButtonItem = {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonPressed))
        backButton.tintColor = .black
        return backButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        presenter?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func setupUI() {
        [progressView, webView].forEach { view.addSubview($0) }
        configureBackButton()
        setupConstraints()
    }
    
    private func configureBackButton() {
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupConstraints() {
        [webView, progressView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
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
    
    func loadAuthView(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }

    func didAuthenticateWithCode(_ code: String) {
        delegate?.webViewViewController(self, didAuthenticateWithCode: code)
    }

    func didFailWithError(_ error: Error) {
        let errorMessage = NetworkErrorHandler.errorMessage(from: error)
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: errorMessage,
            buttons: [AlertButton(title: "OK", style: .cancel, handler: nil)],
            context: .error
        )
        AlertPresenter.showAlert(with: alertModel, delegate: self)
    }

    func didCancel() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    @objc private func backButtonPressed() {
        let alertModel = AlertModel(
            title: "Выход из авторизации",
            message: "Вы уверены, что хотите покинуть страницу авторизации?",
            buttons: [
                AlertButton(title: "Отмена", style: .cancel, handler: nil),
                AlertButton(title: "Выход", style: .destructive, handler: { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.webViewViewControllerDidCancel(self)
                })
            ],
            context: .back
        )
        AlertPresenter.showAlert(with: alertModel, delegate: self)
    }
}

extension WebViewViewController: AlertPresenterDelegate {
    func presentAlert(_ alert: UIAlertController) {
        present(alert, animated: true)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let code = code(from: navigationAction) {
            didAuthenticateWithCode(code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let errorMessage = NetworkErrorHandler.errorMessage(from: error)
        
        let error = NetworkError.emptyData
        didFailWithError(error)
        Logger.shared.log(.error,
                          message: "AuthService: Ошибка при загрузке данных WebView",
                          metadata: ["❌": errorMessage])
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.shared.log(.debug,
                          message: "AuthService: Загрузка завершена:",
                          metadata: ["✅": ""])
        presenter?.didUpdateProgressValue(1.0)
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}
