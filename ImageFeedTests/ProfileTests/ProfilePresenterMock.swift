//
//  ProfilePresenterMock.swift
//  ImageFeedTests
//
//  Created by Konstantin Lyashenko on 17.07.2024.
//

@testable import ImageFeed
import Foundation

final class ProfilePresenterMock: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var exitButtonPressedCalled = false
    var updateProfileImageCalled = false
    var profileImageUrl: String?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func exitButtonPressed() {
        exitButtonPressedCalled = true
    }
    
    func updateProfileImage(with url: String) {
        updateProfileImageCalled = true
        profileImageUrl = url
    }
}
