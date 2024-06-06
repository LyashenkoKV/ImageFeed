//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 31.05.2024.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private let image = UIImageView()
    private let loginButton = UIButton()
    private let webViewViewController = WebViewViewController()
    private let oauth2Service = OAuth2Service.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        webViewViewController.delegate = self
        setupUI()
    }
    
    private func setupUI() {
        configureProfileImage()
        configureLoginButton()
        view.addSubview(image)
        view.addSubview(loginButton)
        setupConstraints()
    }
    
    private func configureProfileImage() {
        image.image = UIImage(named: "VectorAuth")
        image.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureLoginButton() {
        loginButton.setTitle("Войти", for: .normal)
        loginButton.setTitleColor(.ypBlack, for: .normal)
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        loginButton.layer.cornerRadius = 16
        loginButton.layer.masksToBounds = true
        loginButton.backgroundColor = .ypWhite
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 60),
            image.heightAnchor.constraint(equalToConstant: 60),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc func loginButtonPressed() {
        navigationController?.pushViewController(webViewViewController, animated: true)
    }
    
    private func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        oauth2Service.fetchOAuthToken(code: code) { result in
            switch result {
            case .success(let token):
                print("Аутентификация выполнена! Токен: \(token)")
            case .failure(let error):
                let errorMessage = NetworkErrorHandler.errorMessage(from: error)
                self.showErrorAlert(with: errorMessage)
                print("Ошибка аутентификации: \(errorMessage)")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func webViewViewController(_ vc: WebViewViewController, didFailWithError error: any Error) {
        showErrorAlert(with: NetworkErrorHandler.errorMessage(from: error))
    }
}
