//
//  SeededURLSession.swift
//
//  Created by Michael Hayman on 2016-05-18.

typealias DataCompletion = (NSData?, NSURLResponse?, NSError?) -> Void

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

    public class func defaultSession() -> NSURLSession {
        if UIStubber.isRunningAutomationTests() {
            return UIStubber.stubAPICallsSession()
        }
        return NSURLSession.sharedSession()
    }

    override public func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        guard let bundle = retrieveBundle(bundleName: jsonBundle) else { return NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: completionHandler) }
        guard let url = request.URL else { return NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: completionHandler) }

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
            return NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: completionHandler)
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
