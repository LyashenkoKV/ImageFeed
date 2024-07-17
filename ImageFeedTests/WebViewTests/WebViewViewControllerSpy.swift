//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Konstantin Lyashenko on 17.07.2024.
//

@testable import ImageFeed
import WebKit

class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    
    var presenter: AuthPresenterProtocol?
    var loadAuthViewCalled = false
    
    func loadAuthView(request: URLRequest) {
        loadAuthViewCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {}
    
    func setProgressHidden(_ isHidden: Bool) {}
    
    func didAuthenticateWithCode(_ code: String) {}
    
    func didFailWithError(_ error: Error) {}
    
    func didCancel() {}
}
