//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Konstantin Lyashenko on 17.07.2024.
//
@testable import ImageFeed
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
        
        sleep(2)
        
        loginTextField.clearAndEnterText(text: "login") // Очищаю поле (метод в экстеншене) и ввожу email
        app.toolbars["Toolbar"].buttons["Done"].tap()
        webView.swipeUp() // Прокручиваю экран вверх, чтобы открыть поле для пароля
        
        sleep(2)
        
        // Ввожу пароль
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssert(passwordTextField.waitForExistence(timeout: 10)) // Убеждаюсь, что поле ввода пароля существует
        
        passwordTextField.tap() // Выбрать поле
        
        // Копирую пароль в буфер обмена
        UIPasteboard.general.string = "password"
        
        // Вставляю пароль из буфера обмена
        passwordTextField.press(forDuration: 1.1)
        
        app.menuItems["Paste"].tap()
        
        sleep(2)
        
        app.toolbars["Toolbar"].buttons["Done"].tap()
        //webView.swipeUp() // Прокручиваю экран вверх, чтобы открыть кнопку входа
        
        // Нажимаю на кнопку "Login"
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10)) // Убеждаюсь, что кнопка входа существует
        loginButton.tap() // Нажимаю на кнопку входа
        
        // Проверяю, что лента загрузилась
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10)) // Убеждаюсь, что первый элемент ленты существует
    }
    
    func testFeed() throws {
        // Получаю таблицу в приложении
        let tablesQuery = app.tables
        
        // Выбираю первую ячейку и прокручиваю вверх
        let firstCell = tablesQuery.descendants(matching: .cell).element(boundBy: 0)
        
//        // Прокручиваю таблицу до появления второй ячейки
//        firstCell.swipeUp()
//        
//        sleep(2)
        
        // Ожидаю появления второй ячейки
        let secondCell = tablesQuery.descendants(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(secondCell.waitForExistence(timeout: 5)) // Убедиться, что вторая ячейка существует
        
        // Кнопка лайк
        let likeButton = secondCell.buttons["likeButton"]
        
        // Убедиться, что кнопка лайка видима
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5)) // Убедиться, что кнопка лайка существует
        
        // Поставить "лайк"
        likeButton.tap()
        sleep(2)
        
        // Снять "лайк"
        likeButton.tap()
        sleep(5)
        
        // Открываю ячейку
        secondCell.tap()
        
        sleep(2)
        
        // Ожидаю появления изображения
        let image = app.scrollViews.images.element(boundBy: 0)
        // Увеличиваю изображение
        image.pinch(withScale: 3, velocity: 1)
        // Уменьшаею изображение
        image.pinch(withScale: 0.5, velocity: -1)
        
        // Нажимаю кнопку "назад" в nav
        let navBackButtonWhiteButton = app.buttons["backButton"]
        XCTAssertTrue(navBackButtonWhiteButton.waitForExistence(timeout: 5))
        navBackButtonWhiteButton.tap()
        
        // Свайпаю таблицу
        app.swipeUp()
        sleep(2)
    }
    
    func testProfile() throws {
        sleep(3)
        // Переход на вкладку профиля в тапбаре
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        sleep(3)
        
        // Проверка наличия данных с именем и именем пользователя, чтобы убедиться, что профиль загружен корректно
        XCTAssertTrue(app.staticTexts["Konstantin Lyashenko"].exists)
        XCTAssertTrue(app.staticTexts["@lyashenkokv"].exists)
        
        // Нажимаю на кнопку выхода из учетной записи
        app.buttons["logoutButton"].tap()
        
        sleep(5)
        
        // Подтверждение выхода, нажатие на кнопку "Yes" в алерте "Пока, пока!"
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Yes"].tap()
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

// Метод копирует в буфер обмена и вставляет
extension XCUIElement {
    func copyAndEnterText(text: String) {
        // Получаю текущее значение поля ввода
        guard let stringValue = self.value as? String else {
            XCTFail("Пытался очистить и ввести текст в нестроковое значение.")
            return
        }

        // Нажимаю на поле ввода, чтобы активировать его
        self.tap()
        
        // Удаляю текущее значение
        let deleteString = stringValue.map { _ in XCUIKeyboardKey.delete.rawValue }.joined()
        self.typeText(deleteString)
        
        // Ввожу новый текст
        self.typeText(text)
    }
}
