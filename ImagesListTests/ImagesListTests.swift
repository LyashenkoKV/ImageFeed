//
//  ImagesListTests.swift
//  ImagesListTests
//
//  Created by Konstantin Lyashenko on 17.07.2024.
//
@testable import ImageFeed
import XCTest
import UIKit

final class ImagesListTests: XCTestCase {

    var viewController: ImagesListViewController!
    var presenterMock: ImagesListPresenterMock!

    override func setUp() {
        super.setUp()
        viewController = ImagesListViewController()
        presenterMock = ImagesListPresenterMock()
        viewController.configure(presenterMock)
        _ = viewController.view
    }

    override func tearDown() {
        viewController = nil
        presenterMock = nil
        super.tearDown()
    }

    func testViewDidLoadCallsPresenterViewDidLoad() {
        XCTAssertTrue(presenterMock.viewDidLoadCalled)
    }
    
    func testViewDidAppear() {
        viewController.viewDidAppear(false)
        XCTAssertTrue(presenterMock.fetchPhotosCalled)
    }
    
    func testRefreshTableView() {
        viewController.refreshTableView()
        XCTAssertTrue(presenterMock.fetchPhotosCalled)
        // Проверка, что refreshControl закончился
        XCTAssertFalse(viewController.refreshControl.isRefreshing)
    }

    func testViewDidLoadConfiguresTableView() {
        viewController.viewDidLoad()
        XCTAssertNotNil(viewController.tableView.delegate)
        XCTAssertNotNil(viewController.tableView.dataSource)
        XCTAssertEqual(viewController.tableView.separatorStyle, .none)
    }
    
    func testUpdateImagesList() {
        let tableViewMock = UITableViewMock()
        viewController.tableView = tableViewMock
        
        viewController.updateImagesList(startIndex: 0, endIndex: 1)
        
        XCTAssertTrue(tableViewMock.performBatchUpdatesCalled)
    }

    func testConfigCell() {
        let cell = ImagesListCell()
        let presenterMock = ImagesListPresenterMock()

        let photo = Photo(
            id: "1",
            size: CGSize(width: 100, height: 200),
            createdAt: Date(),
            welcomeDescription: "Hello",
            regularImageURL: "http://example.com",
            largeImageURL: "http://example.com",
            isLiked: false
        )

        let dateText = presenterMock.format(date: photo.createdAt)

        cell.configure(with: photo, dateText: dateText, presenter: presenterMock)

        XCTAssertEqual(cell.photoId, photo.id)
        XCTAssertEqual(cell.isLiked, photo.isLiked)
        XCTAssertEqual(cell.customDateLabel.text, dateText)
    }
    
    func testNumberOfRowsInSection() {
        presenterMock.numberOfPhotosReturnValue = 5
        let rows = viewController.tableView(viewController.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rows, 5)
    }
    
    func testCellForRowAt() {
        let tableViewMock = UITableViewMock()
        viewController.tableView = tableViewMock
        
        presenterMock.photoReturnValue = Photo(id: "1", 
                                               size: CGSize(width: 100, height: 100),
                                               createdAt: Date(),
                                               welcomeDescription: "",
                                               regularImageURL: "",
                                               largeImageURL: "",
                                               isLiked: false)
        tableViewMock.dequeueReusableCellReturnValue = ImagesListCell()
        
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(cell is ImagesListCell)
    }

    func testRefreshTableViewCallsFetchPhotos() {
        let expectation = self.expectation(description: "fetchPhotosCalled")

        viewController.refreshTableView()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.presenterMock.fetchPhotosCalled)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testReloadTableViewCallsReloadTableView() {
        let tableViewMock = UITableViewMock()
        viewController.tableView = tableViewMock

        viewController.reloadTableView()

        XCTAssertTrue(tableViewMock.reloadDataCalled)
    }

    func testReloadTableView() {
        viewController.viewDidLoad()
        viewController.reloadTableView()
        XCTAssertEqual(viewController.tableView.visibleCells.count, 0)
    }

    func testShowStubImageView() {
        viewController.showStubImageView(true)
        XCTAssertTrue(viewController.stubImageView.isHidden)

        viewController.showStubImageView(false)
        XCTAssertFalse(viewController.stubImageView.isHidden)
    }

    func testTableViewNumberOfRowsInSection() {
        presenterMock.numberOfPhotosReturnValue = 5
        let numberOfRows = viewController.tableView(viewController.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(numberOfRows, 5)
    }

    func testTableViewHeightForRowAt() {
        let photo = Photo(id: "1", 
                          size: CGSize(width: 100, height: 200),
                          createdAt: Date(),
                          welcomeDescription: "Hello",
                          regularImageURL: "http://example.com",
                          largeImageURL: "http://example.com",
                          isLiked: false)
        presenterMock.photoReturnValue = photo

        let indexPath = IndexPath(row: 0, section: 0)
        let height = viewController.tableView(viewController.tableView, heightForRowAt: indexPath)

        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = viewController.tableView.bounds.width - insets.left - insets.right
        let imageWidth = CGFloat(photo.size.width)
        let scale = imageViewWidth / imageWidth
        let expectedHeight = CGFloat(photo.size.height) * scale + insets.top + insets.bottom

        XCTAssertEqual(height, expectedHeight, accuracy: 0.1)
    }

    func testTableViewWillDisplayCallsFetchPhotos() {
        presenterMock.numberOfPhotosReturnValue = 1
        let indexPath = IndexPath(row: 0, section: 0)
        viewController.tableView(viewController.tableView, willDisplay: UITableViewCell(), forRowAt: indexPath)

        XCTAssertTrue(presenterMock.fetchPhotosCalled)
    }
}
