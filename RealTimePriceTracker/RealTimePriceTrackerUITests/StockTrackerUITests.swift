//
//  StockTrackerUITests.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import XCTest

final class StockTrackerUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - App Launch Tests
    func testAppLaunchesSuccessfully() {
        let navigationBar = app.navigationBars["Stock Tracker"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5.0))
    }

    func testMainScreenElementsExist() {
        // Navigation title
        let navigationBar = app.navigationBars["Stock Tracker"]
        XCTAssertTrue(navigationBar.exists)

        // Connection status
        let connectionStatus = app.staticTexts["Disconnected"]
        XCTAssertTrue(connectionStatus.exists)

        // Start button
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.exists)
        XCTAssertTrue(startButton.isEnabled)

        // Stock list
        let stockList = app.tables.firstMatch
        XCTAssertTrue(stockList.exists)

        // Debug button (added to toolbar)
        let debugButton = app.buttons["Debug"]
        XCTAssertTrue(debugButton.exists)

        // Minimum number of stock symbols
        XCTAssertGreaterThanOrEqual(stockList.cells.count, 20)
    }

    func testStockListContent() {
        let stockList = app.tables.firstMatch
        XCTAssertTrue(stockList.waitForExistence(timeout: 5.0))

        let firstCell = stockList.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)

        // Should contain stock symbol (letters/dots)
        let hasStockSymbol = firstCell.staticTexts.allElementsBoundByIndex.contains { element in
            let text = element.label
            return !text.isEmpty && text.allSatisfy { $0.isLetter || $0 == "." }
        }
        XCTAssertTrue(hasStockSymbol, "Stock symbols should be displayed")

        // Should contain price ($ symbol)
        let hasPrice = firstCell.staticTexts.allElementsBoundByIndex.contains { element in
            element.label.contains("$")
        }
        XCTAssertTrue(hasPrice, "Prices should be displayed with $ symbol")
    }

    // MARK: - Start/Stop Functionality Tests
    func testStartStopTracking() {
        let startButton = app.buttons["Start"]
        let stopButton = app.buttons["Stop"]

        // Initially should show Start button
        XCTAssertTrue(startButton.exists)
        XCTAssertFalse(stopButton.exists)

        // Tap start
        startButton.tap()

        // Should show Stop button
        XCTAssertTrue(stopButton.waitForExistence(timeout: 3.0))
        XCTAssertFalse(startButton.exists)

        // Connection status might change
        let connectingStatus = app.staticTexts["Connecting"]
        let connectedStatus = app.staticTexts["Connected"]
        let failedStatus = app.staticTexts["Failed"]

        // One of these should appear
        let statusChanged = connectingStatus.waitForExistence(timeout: 2.0) ||
                           connectedStatus.waitForExistence(timeout: 2.0) ||
                           failedStatus.waitForExistence(timeout: 2.0)
        XCTAssertTrue(statusChanged, "Connection status should change")

        // Stop tracking
        if stopButton.exists {
            stopButton.tap()
            XCTAssertTrue(startButton.waitForExistence(timeout: 2.0))
        }
    }

    func testDebugViewAccess() {
        // Tap debug button
        let debugButton = app.buttons["Debug"]
        XCTAssertTrue(debugButton.exists)
        debugButton.tap()

        // Debug view should appear
        let debugTitle = app.navigationBars["WebSocket Debug"]
        XCTAssertTrue(debugTitle.waitForExistence(timeout: 2.0))

        // Should have control buttons
        let connectButton = app.buttons["Connect to WebSocket"]
        XCTAssertTrue(connectButton.exists)

        let sendTestButton = app.buttons["Send Test"]
        XCTAssertTrue(sendTestButton.exists)

        let disconnectButton = app.buttons["Disconnect"]
        XCTAssertTrue(disconnectButton.exists)

        // Test connection in debug view
        connectButton.tap()

        // Wait for connection result
        Thread.sleep(forTimeInterval: 2.0)

        // Should show some status change
        let statusTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
        let hasConnectionStatus = statusTexts.contains { text in
            ["Connected", "Connecting", "Failed", "Timeout"].contains(text)
        }
        XCTAssertTrue(hasConnectionStatus, "Should show connection status")

        // Close debug view
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.exists)
        doneButton.tap()

        // Should return to main screen
        let mainNavigationBar = app.navigationBars["Stock Tracker"]
        XCTAssertTrue(mainNavigationBar.waitForExistence(timeout: 2.0))
    }

    // MARK: - Navigation Tests
    func testNavigationToSymbolDetail() {
        let stockList = app.tables.firstMatch
        XCTAssertTrue(stockList.waitForExistence(timeout: 5.0))

        let firstCell = stockList.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)

        // Extract symbol name for verification
        let symbolTexts = firstCell.staticTexts.allElementsBoundByIndex.compactMap { element in
            let text = element.label
            return (!text.isEmpty && text.allSatisfy { $0.isLetter || $0 == "." }) ? text : nil
        }

        guard let expectedSymbol = symbolTexts.first else {
            XCTFail("Could not find symbol text in cell")
            return
        }

        // Tap the cell
        firstCell.tap()

        // Should navigate to detail screen
        let detailNavigationBar = app.navigationBars[expectedSymbol]
        XCTAssertTrue(detailNavigationBar.waitForExistence(timeout: 3.0))

        // Verify detail screen elements
        XCTAssertTrue(app.staticTexts["About"].exists)
        XCTAssertTrue(app.staticTexts["Details"].exists)
        XCTAssertTrue(app.staticTexts["Last Updated"].exists)
    }

    func testBackNavigation() {
        let stockList = app.tables.firstMatch
        let firstCell = stockList.cells.element(boundBy: 0)
        firstCell.tap()

        // Wait for detail screen
        XCTAssertTrue(app.staticTexts["About"].waitForExistence(timeout: 3.0))

        // Go back
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.exists {
            backButton.tap()

            // Should return to main screen
            let mainNavigationBar = app.navigationBars["Stock Tracker"]
            XCTAssertTrue(mainNavigationBar.waitForExistence(timeout: 2.0))
        }
    }

    // MARK: - Accessibility Tests
    func testAccessibilityLabels() {
        // Start button accessibility
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.exists)
        XCTAssertNotEqual(startButton.label, "")
        XCTAssertTrue(startButton.isHittable)

        // Stock list accessibility
        let stockList = app.tables.firstMatch
        let firstCell = stockList.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        XCTAssertTrue(firstCell.isHittable)
        XCTAssertNotEqual(firstCell.label, "")
    }

    func testVoiceOverSupport() {
        // Test basic VoiceOver navigation
        let stockList = app.tables.firstMatch
        let cells = stockList.cells

        XCTAssertGreaterThan(cells.count, 0)

        // Each cell should be accessible
        for i in 0..<min(5, cells.count) {
            let cell = cells.element(boundBy: i)
            XCTAssertTrue(cell.exists)
            XCTAssertTrue(cell.isHittable)
        }
    }

    // MARK: - Performance Tests
    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let newApp = XCUIApplication()
            newApp.launch()
        }
    }

    func testScrollingPerformance() {
        let stockList = app.tables.firstMatch
        XCTAssertTrue(stockList.waitForExistence(timeout: 5.0))

        measure(metrics: [XCTMemoryMetric()]) {
            // Intensive scrolling
            for _ in 0..<10 {
                stockList.swipeUp()
            }
            for _ in 0..<10 {
                stockList.swipeDown()
            }
        }
    }

    // MARK: - Stress Tests
    func testRapidTapping() {
        let stockList = app.tables.firstMatch
        let firstCell = stockList.cells.element(boundBy: 0)

        // Rapid taps should not crash
        for _ in 0..<10 {
            firstCell.tap()
            Thread.sleep(forTimeInterval: 0.1)

            // Go back if navigation occurred
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
            }
        }

        // App should still be responsive
        XCTAssertTrue(stockList.exists)
    }

    func testRepeatedStartStop() {
        let startButton = app.buttons["Start"]
        let stopButton = app.buttons["Stop"]

        // Perform multiple start/stop cycles
        for cycle in 0..<3 {
            // Start
            if startButton.exists {
                startButton.tap()
            }

            Thread.sleep(forTimeInterval: 1.0)

            // Stop
            if stopButton.waitForExistence(timeout: 2.0) {
                stopButton.tap()
            }

            Thread.sleep(forTimeInterval: 0.5)

            // Verify app stability
            let stockList = app.tables.firstMatch
            XCTAssertTrue(stockList.exists, "App should remain stable after cycle \(cycle + 1)")
        }
    }
}
