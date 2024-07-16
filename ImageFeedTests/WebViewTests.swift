//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Konstantin Lyashenko on 15.07.2024.
//
@testable import ImageFeed
import XCTest
import WebKit

final class WebViewPresenterSpy: AuthPresenterProtocol {
    
    var view: WebViewViewControllerProtocol?
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        print("WebViewPresenterSpy: viewDidLoad called")
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {}
    
    func code(from url: URL) -> String? { return nil }
}

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

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        let viewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = AuthPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewController.loadAuthViewCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        let authHelper = AuthHelper()
        let presenter = AuthPresenter(authHelper: authHelper)
        let progress = 0.6
        
        let shouldHideProgress = presenter.shouldHideProgress(for: Float(progress))
        
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        let authHelper = AuthHelper()
        let presenter = AuthPresenter(authHelper: authHelper)
        let progress = 1.0
        
        let shouldHideProgress = presenter.shouldHideProgress(for: Float(progress))
        
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        let url = authHelper.authURL()
        let urlString = url
        
        XCTAssertTrue(urlString!.contains(configuration.authURLString))
        XCTAssertTrue(urlString!.contains(configuration.accessKey))
        XCTAssertTrue(urlString!.contains(configuration.redirectURI))
        XCTAssertTrue(urlString!.contains("code"))
        XCTAssertTrue(urlString!.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()
        let code = authHelper.code(from: url)
        
        XCTAssertEqual(code, "test code")
    }
}


