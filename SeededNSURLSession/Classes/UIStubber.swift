//
//  SeededDataTask.swift
//
//  Created by Michael Hayman on 2016-05-18.

@objc public class UIStubber: NSObject {
    public class func session() -> NSURLSession {
        if isRunningAutomationTests() {
            return stubAPICallsSession()
        } else {
            return NSURLSession.sharedSession()
        }
    }

    public class func isRunningAutomationTests() -> Bool {
        if NSProcessInfo.processInfo().arguments.contains("RUNNING_AUTOMATION_TESTS") {
            return true
        }
        return false
    }

    public class func stubAPICallsSession() -> NSURLSession {
        // e.g. if 'STUB_API_CALLS_stubsTemplate_addresses' is received as argument
        // we globally stub the app using the 'stubsTemplate_addresses.bundle'
        let stubPrefix = "STUB_API_CALLS_"

        let stubPrefixForPredicate = stubPrefix.stringByAppendingString("*");

        let predicate = NSPredicate(format: "SELF like %@", stubPrefixForPredicate)

        let filteredArray = NSProcessInfo.processInfo().arguments.filter { predicate.evaluateWithObject($0) }

        let bundleName = filteredArray.first?.stringByReplacingOccurrencesOfString(stubPrefix, withString: "")

        if let bundleName = bundleName {
            return SeededURLSession(jsonBundle: bundleName)
        } else {
            return NSURLSession.sharedSession()
        }
    }
}
