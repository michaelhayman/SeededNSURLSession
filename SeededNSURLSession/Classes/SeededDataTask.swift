//
//  SeededDataTask.swift
//
//  Created by Michael Hayman on 2016-05-18.

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
        completion(data, nextResponse, nextError)
    }
}
