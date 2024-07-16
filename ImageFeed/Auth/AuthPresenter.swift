//
//  AuthService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 04.06.2024.


import Foundation
import WebKit
// MARK: - Protocol
protocol AuthPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

// MARK: - Object
class AuthPresenter: NSObject {
    weak var view: WebViewViewControllerProtocol?
    private let authHelper: AuthHelperProtocol

    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
        super.init()
    }
}

// MARK: - AuthPresenterProtocol
extension AuthPresenter: AuthPresenterProtocol {

    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        
        view?.loadAuthView(request: request)
        didUpdateProgressValue(0)
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

