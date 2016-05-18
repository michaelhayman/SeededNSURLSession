//
//  SeededURLSession.swift
//
//  Created by Michael Hayman on 2016-05-16.

typealias DataCompletion = (NSData?, NSURLResponse?, NSError?) -> Void

let MappingFilename = "stubRules"
let MatchingURL = "matching_url"
let JSONFile = "json_file"
let StatusCode = "status_code"
let HTTPMethod = "http_method"
let InlineResponse = "inline_response"

@objc public class SeededURLSession: NSURLSession {
    let jsonBundle: String!

    public init(jsonBundle jsonBundle: String) {
        self.jsonBundle = jsonBundle
    }

    class func retrieveBundle(bundleName bundleName: String) -> NSBundle? {
        let bundlePath = NSBundle.mainBundle().pathForResource(bundleName, ofType: "bundle")!
        let bundle = NSBundle(path: bundlePath)
        return bundle
    }

    class func retrieveMappingsForBundle(bundle bundle: NSBundle) -> [NSDictionary]? {
        let mappingFilePath = bundle.pathForResource(MappingFilename, ofType: "plist")
        let mappings = NSArray(contentsOfFile: mappingFilePath!) as! [NSDictionary]
        return mappings
    }

    override public func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        let bundle = SeededURLSession.retrieveBundle(bundleName: jsonBundle)
        let mappings = SeededURLSession.retrieveMappingsForBundle(bundle: bundle!)

        // go through mappings and match by url

        let mapping = mappings?.filter({ (mapping) -> Bool in
            let regexPattern = mapping[MatchingURL] as! String
            var regex: NSRegularExpression

            do {
                regex = try NSRegularExpression(pattern: regexPattern, options: [])
            } catch {
                print(error)
                return false
            }

            if regex.firstMatchInString(request.URL!.absoluteString, options: [], range: NSMakeRange(0, request.URL!.absoluteString.characters.count)) != nil {
                return true
            }
            return false
        }).first

        let jsonFileName = mapping![JSONFile] as! String
        let path = bundle!.pathForResource(jsonFileName, ofType: "json")

        let data = NSData(contentsOfFile: path!)

        let statusCodeString = mapping![StatusCode] as! String
        let statusCode = Int(statusCodeString)!

        let task = SeededDataTask(url: request.URL!, completion: completionHandler)

        if statusCode == 422 || statusCode == 500 {
            let error = NSError(domain: NSURLErrorDomain, code: Int(CFNetworkErrors.CFURLErrorCannotLoadFromNetwork.rawValue), userInfo: nil)
            task.nextError = error
        }

        let response = NSHTTPURLResponse(URL: request.URL!, statusCode: statusCode, HTTPVersion: nil, headerFields: nil)

        task.data = data
        task.nextResponse = response
        return task
    }
}
