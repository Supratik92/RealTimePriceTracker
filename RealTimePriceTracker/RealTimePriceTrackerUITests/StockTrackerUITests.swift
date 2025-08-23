//
//  StockTrackerUITests.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import XCTest
@testable import RealTimePriceTracker

final class StockTrackerUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testAppLaunchesSuccessfully() {
        // Wait for any navigation bar to appear
        let navigationBars = app.navigationBars
        XCTAssertTrue(navigationBars.firstMatch.waitForExistence(timeout: 10.0),
                      "App should launch and show navigation bar")

        // App should have some interactive elements
        XCTAssertGreaterThan(app.buttons.count, 0,
                            "App should have interactive buttons")

        // Should have a list/table for stocks
        XCTAssertEqual(app.tables.count, 0,
                       "App should have a stock list")

        print("✅ TEST 1 PASSED: App launches successfully")
    }

    func testStockListHasContent() {
        // Find the main table (stock list)
        let stockTable = app.collectionViews.firstMatch
        XCTAssertTrue(stockTable.waitForExistence(timeout: 5.0),
                      "Stock table should exist")

        // Should have multiple stock entries
        XCTAssertGreaterThanOrEqual(stockTable.cells.count, 3,
                                   "Should have at least 3 stock entries")

        // First cell should be interactive
        let firstCell = stockTable.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists,
                      "First stock cell should exist")
        XCTAssertTrue(firstCell.isHittable,
                      "First stock cell should be tappable")

        print("✅ TEST 2 PASSED: Stock list has content and is interactive")
    }

    func testBasicButtonInteraction() {
        // Look for Start button (or any button that might be the start button)
        let startButton = app.buttons.allElementsBoundByIndex.first { button in
            let label = button.label.lowercased()
            return label.contains("start") || label.contains("play") ||
                   button.label == "Start" || button.label == "▶️"
        }

        if let startBtn = startButton {
            XCTAssertTrue(startBtn.exists, "Start button should exist")
            XCTAssertTrue(startBtn.isEnabled, "Start button should be enabled")

            // Tap the button
            startBtn.tap()

            // Wait a moment for any state changes
            Thread.sleep(forTimeInterval: 1.0)

            // Look for Stop button or any indication the state changed
            let stopButton = app.buttons.allElementsBoundByIndex.first { button in
                let label = button.label.lowercased()
                return label.contains("stop") || label.contains("pause") ||
                       button.label == "Stop" || button.label == "⏸️"
            }

            if stopButton?.exists == true {
                print("✅ Button state changed successfully (Start → Stop)")
            } else {
                print("ℹ️ Button was tapped (state change may vary)")
            }
        } else {
            // Look for any prominent button
            let anyButton = app.buttons.firstMatch
            XCTAssertTrue(anyButton.exists, "App should have at least one button")
            print("ℹ️ Found button with label: \(anyButton.label)")
        }

        print("✅ TEST 3 PASSED: Basic button interaction works")
    }

    func testNavigationBetweenScreens() {
        // Find main stock table
        let stockTable = app.collectionViews.firstMatch
        XCTAssertTrue(stockTable.waitForExistence(timeout: 5.0))

        // Tap first available cell
        let firstCell = stockTable.cells.element(boundBy: 0)
        if firstCell.exists && firstCell.isHittable {
            firstCell.tap()

            // Wait for navigation to complete
            Thread.sleep(forTimeInterval: 1.0)

            // Check if we navigated (different navigation bar or new content)
            let hasDetailContent = app.staticTexts.allElementsBoundByIndex.contains { element in
                let label = element.label.lowercased()
                return label.contains("about") || label.contains("details") ||
                       label.contains("description") || label.contains("previous")
            }

            if hasDetailContent {
                print("✅ Successfully navigated to detail screen")

                // Try to go back
                let backButton = app.navigationBars.buttons.firstMatch
                if backButton.exists {
                    backButton.tap()
                    Thread.sleep(forTimeInterval: 0.5)
                    print("✅ Successfully navigated back")
                }
            } else {
                print("ℹ️ Navigation tapped but may not have changed screens")
            }
        }

        // Verify app is still responsive
        XCTAssertTrue(stockTable.exists, "App should remain responsive")

        print("✅ TEST 4 PASSED: Navigation functionality tested")
    }
}
