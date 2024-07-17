//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Konstantin Lyashenko on 17.07.2024.
//

@testable import ImageFeed
import UIKit

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var showProfileDetailsCalled = false
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var updateProfileImageCalled = false

    func showProfileDetails(profile: Profile) {
        showProfileDetailsCalled = true
    }

    func showLoading() {
        showLoadingCalled = true
    }

    func hideLoading() {
        hideLoadingCalled = true
    }

    func updateProfileImage(with image: UIImage) {
        updateProfileImageCalled = true
    }
}
