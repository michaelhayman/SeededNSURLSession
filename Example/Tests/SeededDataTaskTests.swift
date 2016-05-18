import UIKit
import XCTest
import SeededNSURLSession

class SeededDataTaskTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPostToSignUp() {
        guard let requestURL = NSURL(string: "https://example.com/sign_up") else {
            XCTFail("Invalid URL.")
            return
        }

        let e = expectationWithDescription("Hitting sign up endpoint")

        let session = SeededURLSession(jsonBundle: "http_success_stubs")
        XCTAssertNotNil(session)

        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "POST"

        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in

            XCTAssertNil(error)
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
            self.verifySignUpData(data!)

            e.fulfill()

        }).resume()

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testMedications() {
        guard let requestURL = NSURL(string: "https://example.com/medications") else {
            XCTFail("Invalid URL.")
            return
        }

        let e = expectationWithDescription("Hitting medications endpoint")

        let session = SeededURLSession(jsonBundle: "http_success_stubs")
        XCTAssertNotNil(session)

        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "GET"

        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in

            XCTAssertNil(error)
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)

            e.fulfill()

        }).resume()

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testSpecificFailingStub() {
        let session = SeededURLSession(jsonBundle: "http_failure_stubs")

        guard let requestURL = NSURL(string: "https://example.com/sign_up") else {
            XCTFail("Invalid URL.")
            return
        }

        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "POST"

        let e = expectationWithDescription("Hitting sign up endpoint and it should fail")

        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                XCTAssertNotNil(error)
            } else {
                XCTFail("There should be an error here.")
            }

            e.fulfill()
        }).resume()

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func verifySignUpData(data: NSData) {
        if let json = NSString(data: data, encoding: NSUTF8StringEncoding) {
            XCTAssertNotNil(json)
            let expectedString = "{\n    \"access_token\": \"asdf\"\n}"
            XCTAssertEqual(expectedString, json)
        } else {
            XCTFail("Failed to convert data to string.")
        }
    }
}
