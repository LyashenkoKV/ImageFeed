//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Konstantin Lyashenko on 15.07.2024.
//
@testable import ImageFeed
import XCTest
import WebKit

final class WebViewTests: XCTestCase {
    
    var viewController: WebViewViewController!
    var presenter: WebViewPresenterSpy!
    
    override func setUp() {
        super.setUp()
        
        viewController = WebViewViewController()
        presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
    }
    
    override func tearDown() {
        viewController = nil
        presenter = nil
        
        super.tearDown()
    }
    
    func testViewControllerCallsViewDidLoad() {
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}

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
