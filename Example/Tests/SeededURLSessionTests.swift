import UIKit
import XCTest
import SeededNSURLSession

class SeededURLSessionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    let falseMatch = "matched on wrong string"
    
    func testExample() {
        let session = SeededURLSession(jsonBundle: "hey")
        let urlString = "https://test.obvion.nl/web/proxy/requests/538112"

        XCTAssertFalse(session.findMatch(path: ".*/requests", url: urlString), falseMatch)
        XCTAssertFalse(session.findMatch(path: ".*/requests/", url: urlString), falseMatch)
        XCTAssert(session.findMatch(path: ".*/requests/538112", url: urlString))
    }

    func testAnotherExample() {
        let session = SeededURLSession(jsonBundle: "hey")
        let urlString = "https://test.obvion.nl/web/proxy/requests/"

        XCTAssertFalse(session.findMatch(path: ".*/requests", url: urlString), falseMatch)
        XCTAssert(session.findMatch(path: ".*/requests/", url: urlString), falseMatch)
        XCTAssertFalse(session.findMatch(path: ".*/requests/538112", url: urlString))
    }

    func testYetAnotherExample() {
        let session = SeededURLSession(jsonBundle: "hey")
        let urlString = "https://test.obvion.nl/web/proxy/elevate/asdf?loginPreference=email"

        XCTAssertFalse(session.findMatch(path: ".*/elevate", url: urlString), falseMatch)
        XCTAssert(session.findMatch(path: ".*/elevate.*", url: urlString))
    }
}
