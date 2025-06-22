//
//  HealthKitTestDataRegisterUITestsLaunchTests.swift
//  HealthKitTestDataRegisterUITests
//
//  Created by 佐藤汰一 on 2025/06/17.
//

import XCTest

@MainActor
final class HealthKitTestDataRegisterUITestsLaunchTests: XCTestCase {
    
    let app = XCUIApplication()
    
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchEnvironment = ProcessInfo.processInfo.environment
        app.resetAuthorizationStatus(for: .health)
        app.launch()
    }
    
    func testLaunch() throws {
        
        app.buttons["Register"].tap()
        let _ = app.buttons["許可"].waitForExistence(timeout: 5)
        
        app.switches.allElementsBoundByIndex.forEach { $0.tap() }
        app.buttons["許可"].tap()
        
        XCTAssertTrue(app.staticTexts["OK"].waitForExistence(timeout: 5))
    }
}
