//
//  SampleData.swift
//
//  Created by Michael Hayman on 2016-05-18.

@objc public class SampleData: NSObject {
    public class func retrieveDataFromBundleWithName(bundle bundleName: String, resource: String) -> NSData? {
        let bundle = NSBundle.mainBundle()

        guard let bundlePath = bundle.pathForResource(bundleName, ofType: "bundle") else { return nil }
        guard let jsonBundle = NSBundle(path: bundlePath) else { return nil }
        guard let path = jsonBundle.pathForResource(resource, ofType: "json") else { return nil }

        return NSData(contentsOfFile: path)
    }
}
