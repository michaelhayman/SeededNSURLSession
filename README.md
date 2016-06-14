# SeededNSURLSession

## Overview

Quickly stub out the network for both your unit tests and UI tests in as few lines of
code as possible.

Concentrate on maintaining the JSON as returned from the API in a few bundles inside of your app.

The basis for this technique came from an article on the
[justeat blog](http://tech.just-eat.com/2015/11/23/offline-ui-testing-on-ios-with-stubs/).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

You can also run the tests to understand how the library works from within the demo.

## Installation

### Cocoapods

SeededNSURLSession is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile for both your main target and your
unit test target:

```ruby
pod "SeededNSURLSession"
```

## Usage

### Target

Add the JSON response bundles to your main target so they can be accessed by both UI
and unit tests.

### JSON response bundles

The bundles consist of a rules plist file which specifies what type of response to stub
and which JSON to load for that response.

There are examples in the demo.

The URLs in the response bundles accept regular expressions. See the tests and the
bundles for examples.

### UI Tests

Because the UI tests don't have their own specialized environment, the session must
be detected at runtime by passing in launch arguments.  If you pass the following
arguments, and use `SeededNSURLSession.defaultSession()` as your session, the
library will look for mocks for every API request you make.

```swift
app = XCUIApplication()

app.launchArguments = [
    "STUB_API_CALLS_http_success_stubs",
    "RUNNING_AUTOMATION_TESTS"
]
```

The string `http_success_stubs` should be replaced with the name of the
JSON responses bundle you are loading. For example, you can load a bundle called
`http_failure_stubs` to test your error code.

### Unit tests

Add the following code to your unit test:

```swift
@import SeededNSURLSession

class UserTests: XCTestCase {
	func testLoginSuccess() {
        let session = SeededURLSession(jsonBundle: "http_success_stubs")

		mockUser.login(session: session) { (user, error) in
			XCTAssertNotNil(user)
		}
	}
}
```
There are additional methods to:

* apply the stubs in each bundle selectively;
* load the JSON from a stub into an NSData object (for example to test your parser code)

## Tests

After doing a `pod install` in the `Example` project:

```
xcodebuild \
    -workspace Example/SeededNSURLSession.xcworkspace \
    -scheme SeededNSURLSession-Example \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 6,OS=9.3' \
    test
````

## Author

Michael Hayman, michael@springbox.ca

## License

SeededNSURLSession is available under the MIT license. See the LICENSE file for more info.

