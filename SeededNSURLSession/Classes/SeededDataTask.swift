//
//  SeededDataTask.swift
//
//  Created by Michael Hayman on 2016-05-16.

@objc public class SeededDataTask: NSURLSessionDataTask {
    private let url: NSURL
    private let completion: DataCompletion
    var data: NSData?
    var nextError: NSError?
    var nextResponse: NSHTTPURLResponse?

    init(url: NSURL, completion: DataCompletion) {
        self.url = url
        self.completion = completion
        self.data = nil
    }

    override public func resume() {
        // load all the stubs
        // find the most relevant one, based on the URL
        // return that as the response otherwise return nothing?

        completion(data, nextResponse, nextError)
    }
}
