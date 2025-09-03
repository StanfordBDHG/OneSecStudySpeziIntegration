//
// This source file is part of the SpeziOneSec open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OSLog
import XCTest


class TestAppUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }
    

    @MainActor
    func testWebViewAlertAndConfirmHooks() {
        let app = XCUIApplication()
        app.launch()
        XCTAssert(app.wait(for: .runningForeground, timeout: 2))
        app.buttons["Test Alert/Confirm"].tap()
        
        sleep(5)
        
        let webView = app.webViews.firstMatch
        let alertStatus = webView.otherElements["Alert Status"]
        let confirmStatus = webView.otherElements["Confirm Status"]
        
        XCTAssert(alertStatus.staticTexts["Not triggered"].waitForExistence(timeout: 1))
        webView.buttons["Trigger alert()"].tap()
        // ideally we'd also assert that the alert (or confirm) status changes to "active" while presented,
        // but we skip that bc for some reason the web view's contents aren't part of the view hierarchy while the alert/sheet is active.
        XCTAssert(app.alerts.staticTexts["This is the window.alert() test!"].waitForExistence(timeout: 2))
        app.alerts.buttons["OK"].tap()
        XCTAssert(alertStatus.staticTexts["Alert dismissed"].waitForExistence(timeout: 2))
        
        XCTAssert(confirmStatus.staticTexts["Not triggered"].waitForExistence(timeout: 1))
        webView.buttons["Trigger confirm()"].tap()
        XCTAssert(app.alerts.staticTexts["This is the window.confirm() test!"].waitForExistence(timeout: 2))
        app.alerts.buttons["OK"].tap()
        XCTAssert(confirmStatus.staticTexts["Confirm dismissed; response=true"].waitForExistence(timeout: 2))
        webView.buttons["Trigger confirm()"].tap()
        XCTAssert(app.alerts.staticTexts["This is the window.confirm() test!"].waitForExistence(timeout: 2))
        app.alerts.buttons["Cancel"].tap()
        XCTAssert(confirmStatus.staticTexts["Confirm dismissed; response=false"].waitForExistence(timeout: 2))
    }
}
