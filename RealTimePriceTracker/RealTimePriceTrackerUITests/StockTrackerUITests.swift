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

}
