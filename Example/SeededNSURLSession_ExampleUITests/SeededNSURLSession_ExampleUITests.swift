//
//  SeededNSURLSession_ExampleUITests.swift
//
//  Created by Michael Hayman on 2016-05-18.
//

import XCTest

class SeededNSURLSession_ExampleUITests: XCTestCase {

    func testUI() {
        continueAfterFailure = false
        let app = XCUIApplication()

        app.launchArguments = [
            "STUB_API_CALLS_http_success_stubs",
            "RUNNING_AUTOMATION_TESTS"
        ]

        app.launch()

        XCTAssert(app.staticTexts["Prozac"].exists)
    }
    
}
