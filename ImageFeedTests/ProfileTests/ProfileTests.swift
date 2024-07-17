//
//  ProfileTests.swift
//  ProfileTests
//
//  Created by Konstantin Lyashenko on 16.07.2024.
//
@testable import ImageFeed
import XCTest
import UIKit

class ProfileViewControllerTests: XCTestCase {
    
    var viewController: ProfileViewController!
    var presenterMock: ProfilePresenterMock!
    var profileVCSpy: ProfileViewControllerSpy!
    
    override func setUp() {
        super.setUp()
        viewController = ProfileViewController()
        presenterMock = ProfilePresenterMock()
        profileVCSpy = ProfileViewControllerSpy()
        viewController.configure(presenterMock)
        _ = viewController.view
    }
    
    override func tearDown() {
        viewController = nil
        presenterMock = nil
        profileVCSpy = nil
        super.tearDown()
    }
    
    func testViewDidLoadCallsPresenterViewDidLoad() {
        XCTAssertTrue(presenterMock.viewDidLoadCalled)
    }
    
    func testExitButtonPressedCallsPresenterExitButtonPressed() {
        viewController.exitButtonPressed()
        XCTAssertTrue(presenterMock.exitButtonPressedCalled)
    }
    
    func testShowLoadingDisplaysLoadingView() {
        viewController.showLoading()
        XCTAssertFalse(viewController.profileLoadingView.isHidden)
    }
    
    func testHideLoadingHidesLoadingView() {
        viewController.hideLoading()
        XCTAssertNil(viewController.profileLoadingView.superview)
    }
    
    func testShowProfileDetailsUpdatesUI() {
        let profile = Profile(userProfile: ProfileResult(userName: "@johndoe", firstName: "John", lastName: "Doe", bio: "Developer"))
        viewController.showProfileDetails(profile: profile)
        
        XCTAssertEqual(viewController.nameLabel.text, profile.name)
        XCTAssertEqual(viewController.loginNameLabel.text, profile.loginName)
        XCTAssertEqual(viewController.descriptionLabel.text, profile.bio)
    }
    
    func testUpdateProfileImageUpdatesImageView() {
        let image = UIImage(systemName: "person.crop.circle.fill")!
        viewController.updateProfileImage(with: image)
        XCTAssertEqual(viewController.profileImage.image, image)
    }
    
    func testShowProfileDetailsCallsShowProfileDetails() {
        profileVCSpy.showProfileDetails(profile: Profile(userProfile: ProfileResult(userName: "@johndoe", firstName: "John", lastName: "Doe", bio: "Developer")))
        XCTAssertTrue(profileVCSpy.showProfileDetailsCalled)
    }
    
    func testShowLoadingCallsShowLoading() {
        profileVCSpy.showLoading()
        XCTAssertTrue(profileVCSpy.showLoadingCalled)
    }
    
    func testHideLoadingCallsHideLoading() {
        profileVCSpy.hideLoading()
        XCTAssertTrue(profileVCSpy.hideLoadingCalled)
    }
    
    func testUpdateProfileImageCallsUpdateProfileImage() {
        profileVCSpy.updateProfileImage(with: UIImage(systemName: "person.crop.circle.fill")!)
        XCTAssertTrue(profileVCSpy.updateProfileImageCalled)
    }
}
