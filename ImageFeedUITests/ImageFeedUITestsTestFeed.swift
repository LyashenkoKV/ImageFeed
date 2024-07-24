//
//  ImageFeedUITestsTestFeed.swift
//  ImageFeedUITests
//
//  Created by Konstantin Lyashenko on 22.07.2024.
//
@testable import ImageFeed
import XCTest
import Foundation

final class ImageFeedUITestsTestFeed: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("UITestMode")
        app.launch()
    }
    
    func testFirstCellExists() {
        // Дождаюсь загрузки таблицы
        let tableView = app.tables["ImagesListTableView"]
        XCTAssertTrue(tableView.waitForExistence(timeout: 5), "Таблица не загрузилась")
        
        // Проверяю существование первой ячейки
        let firstCell = tableView.cells["cell_0"]
        XCTAssertTrue(firstCell.exists, "Первая ячейка не существует")
        
        // Логи и снимки экрана
        if !firstCell.exists {
            XCTContext.runActivity(named: "Снимок экрана при ошибке") { _ in
                let screenshot = app.screenshot()
                let attachment = XCTAttachment(screenshot: screenshot)
                attachment.lifetime = .keepAlways
                add(attachment)
            }
        }
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        // Ожидаю появление первой ячейки
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 20))
        
        // Ожидаю появление второй ячейки
        let secondCell = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(secondCell.waitForExistence(timeout: 5))
        
        // Проверяю наличие кнопки лайка
        let likeButton = secondCell.buttons["likeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        
        // Скроллю до второй ячейки
        secondCell.scrollIntoView()
        
        // Тапаю по лайку
        likeButton.tap()
        likeButton.tap()
        
        // Тапаю по ячейке
        secondCell.tap()
        
        // Открываю SingleVC
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 30))
        
        // Увеличиваю, уменьшаю
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        // Тапаю назад
        let navBackButton = app.buttons["backButton"]
        XCTAssertTrue(navBackButton.waitForExistence(timeout: 5))
        navBackButton.tap()
        // Свайпаю вверх
        app.swipeUp()
    }
}

extension XCUIElement {
    
    func scrollIntoView() {
        while !self.isHittable {
            XCUIApplication().swipeUp() // Скроллю вверх, пока элемент не станет доступен для взаимодействия
        }
    }
}
