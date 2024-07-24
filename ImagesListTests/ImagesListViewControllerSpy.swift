//
//  ImagesListViewControllerSpy.swift
//  ImagesListTests
//
//  Created by Konstantin Lyashenko on 17.07.2024.
//

@testable import ImageFeed
import XCTest
import UIKit

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateImagesListCalled = false
    var reloadTableViewCalled = false
    var showStubImageViewCalled = false
    var showStubImageViewIsHidden: Bool?
    
    func updateImagesList(startIndex: Int, endIndex: Int) {
        updateImagesListCalled = true
    }
    
    func reloadTableView() {
        reloadTableViewCalled = true
    }
    
    func showStubImageView(_ isHidden: Bool) {
        showStubImageViewCalled = true
        showStubImageViewIsHidden = isHidden
    }
}
