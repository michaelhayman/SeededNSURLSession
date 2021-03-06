//
//  SeededURLSession.swift
//
//  Created by Michael Hayman on 2016-05-18.

let MappingFilename = "stubRules"
let MatchingURL = "matching_url"
let JSONFile = "json_file"
let StatusCode = "status_code"
let HTTPMethod = "http_method"
let InlineResponse = "inline_response"

@objc public class SeededURLSession: NSURLSession {
    let jsonBundle: String!

    public init(jsonBundle named: String) {
        self.jsonBundle = named
    }

    public class func defaultSession(queue: NSOperationQueue = NSOperationQueue.mainQueue()) -> NSURLSession {
        if UIStubber.isRunningAutomationTests() {
            return UIStubber.stubAPICallsSession()
        }
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: queue)

        return session
    }

    override public func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        guard let url = request.URL else { return errorTask(request.URL, reason: "No URL specified", completionHandler: completionHandler) }
        guard let bundle = retrieveBundle(bundleName: jsonBundle) else { return errorTask(url, reason: "No such bundle '\(jsonBundle)' found.", completionHandler: completionHandler) }

        let mappings = retrieveMappingsForBundle(bundle: bundle)

        let mapping = mappings?.filter({ (mapping) -> Bool in
            let httpMethodMatch = request.HTTPMethod == mapping[HTTPMethod] as! String
            let urlMatch = findMatch(path: mapping[MatchingURL], url: url.absoluteString)
            return urlMatch && httpMethodMatch
        }).first

        if let mapping = mapping,
            jsonFileName = mapping[JSONFile] as? String,
            statusString = mapping[StatusCode] as? String,
            statusCode = Int(statusString) {

            var data: NSData?
            if let path = bundle.pathForResource(jsonFileName, ofType: "json") {
                data = NSData(contentsOfFile: path)
            } else {
                if let response = mapping[InlineResponse] as? String {
                    data = response.dataUsingEncoding(NSUTF8StringEncoding)
                }
            }

            let task = SeededDataTask(url: url, completion: completionHandler)

            if statusCode == 422 || statusCode == 500 {
                let error = NSError(domain: NSURLErrorDomain, code: Int(CFNetworkErrors.CFURLErrorCannotLoadFromNetwork.rawValue), userInfo: nil)
                task.nextError = error
            }

            let response = NSHTTPURLResponse(URL: url, statusCode: statusCode, HTTPVersion: nil, headerFields: nil)

            task.data = data
            task.nextResponse = response
            return task
        } else {
            return errorTask(url, reason: "No mapping found.", completionHandler: completionHandler)
        }
    }

    public func findMatch(path path: AnyObject?, url: String) -> Bool {
        guard let regexPattern = path as? String else { return false }

        let modifiedPattern = regexPattern.stringByAppendingString("$")

        if let _ = url.rangeOfString(modifiedPattern, options: .RegularExpressionSearch) {
            return true
        }

        return false
    }

    func retrieveBundle(bundleName bundleName: String) -> NSBundle? {
        guard let bundlePath = NSBundle.mainBundle().pathForResource(bundleName, ofType: "bundle") else { return nil }
        let bundle = NSBundle(path: bundlePath)
        return bundle
    }

    func retrieveMappingsForBundle(bundle bundle: NSBundle) -> [NSDictionary]? {
        guard let mappingFilePath = bundle.pathForResource(MappingFilename, ofType: "plist") else { return nil }
        guard let mappings = NSArray(contentsOfFile: mappingFilePath) as? [NSDictionary] else { return nil }
        return mappings
    }
}

// MARK - Error cases
extension SeededURLSession {
    func errorTask(url: NSURL?, reason: String, completionHandler: DataCompletion) -> SeededDataTask {
        var assignedUrl: NSURL! = url == nil ? NSURL(string: "http://www.example.com/") : url

        let task = SeededDataTask(url: assignedUrl, completion: completionHandler)
        task.nextError = NSError(reason: reason)
        return task
    }
}

extension NSError {
    convenience init(reason: String) {
        let errorInfo = [
            NSLocalizedDescriptionKey: reason,
            NSLocalizedFailureReasonErrorKey: reason,
            NSLocalizedRecoverySuggestionErrorKey: ""
        ]
        self.init(domain: "SeededURLSession", code: 55, userInfo: errorInfo)
    }
}
