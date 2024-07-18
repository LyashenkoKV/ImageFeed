//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Konstantin Lyashenko on 17.07.2024.
//

import XCTest
import WebKit

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        // Нажимаю на кнопку "Authenticate"
        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 10)) // Убеждаюсь, что кнопка существует
        authenticateButton.tap()
        
        // Жду появления webView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 20)) // Убеждаюсь, что webView появился
        
        // Ввожу email
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10)) // Убеждаюсь, что поле для email существует
        loginTextField.tap() // Нажимаю на поле для email
        loginTextField.clearAndEnterText(text: "lyashenkokv@gmail.com") // Очищаю поле (метод в экстеншене) и ввожу email
        webView.swipeUp() // Прокручиваю экран вверх, чтобы открыть поле для пароля
        
        // Ввожу пароль
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10)) // Убеждаюсь, что поле для пароля существует
        passwordTextField.tap() // Нажимаю на поле для пароля
        passwordTextField.clearAndEnterText(text: "vaBqi7-bumvid-nogtad") // Очищаю поле и ввожу пароль
        webView.swipeUp() // Прокручиваю экран вверх, чтобы открыть кнопку входа
        
        // Нажимаю на кнопку "Login"
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10)) // Убеждаюсь, что кнопка входа существует
        loginButton.tap() // Нажимаю на кнопку входа
        
        // Проверяю, что лента загрузилась
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10)) // Убеждаюсь, что первый элемент ленты существует
    }
    
    
}

// Расширение для очистки и ввода текста в поля
extension XCUIElement {
    func clearAndEnterText(text: String) {
        self.tap() // Нажать на элемент
        self.doubleTap() // Двойной клик, чтобы выделить весь текст
        self.typeText("\u{8}") // Ввожу символ backspace для удаления существующего текста
        self.typeText(text) // Ввожу новый текст
    }
}
