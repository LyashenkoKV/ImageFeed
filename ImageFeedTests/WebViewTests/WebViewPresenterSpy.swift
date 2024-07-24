//
//  WebViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Konstantin Lyashenko on 17.07.2024.
//

@testable import ImageFeed
import WebKit

final class WebViewPresenterSpy: AuthPresenterProtocol {
    
    var view: WebViewViewControllerProtocol?
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {}
    
    func code(from url: URL) -> String? { return nil }
}
