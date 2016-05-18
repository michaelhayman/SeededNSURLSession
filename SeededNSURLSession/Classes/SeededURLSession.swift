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

    public init(jsonBundle jsonBundle: String) {
        self.jsonBundle = jsonBundle
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

    override public func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        guard let bundle = retrieveBundle(bundleName: jsonBundle) else { return super.dataTaskWithRequest(request, completionHandler: completionHandler) }
        guard let url = request.URL else { return super.dataTaskWithRequest(request, completionHandler: completionHandler) }

        let mappings = retrieveMappingsForBundle(bundle: bundle)

        let mapping = mappings?.filter({ (mapping) -> Bool in
            guard let regexPattern = mapping[MatchingURL] as? String else { return false }

            var regex: NSRegularExpression

            do {
                regex = try NSRegularExpression(pattern: regexPattern, options: [])
            } catch {
                print(error)
                return false
            }

            if regex.firstMatchInString(url.absoluteString, options: [], range: NSMakeRange(0, url.absoluteString.characters.count)) != nil {
                return true
            }

            return false
        }).first

        if let mapping = mapping,
            jsonFileName = mapping[JSONFile] as? String,
            statusString = mapping[StatusCode] as? String,
            statusCode = Int(statusString),
            path = bundle.pathForResource(jsonFileName, ofType: "json") {

            let data = NSData(contentsOfFile: path)

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
            return super.dataTaskWithRequest(request, completionHandler: completionHandler)
        }
    }
}
