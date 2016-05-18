//
//  ViewController.swift
//  SeededNSURLSession
//
//  Created by Michael Hayman on 05/18/2016.
//  Copyright (c) 2016 Michael Hayman. All rights reserved.
//

import UIKit
import SeededNSURLSession

class ViewController: UIViewController {

    @IBOutlet weak var medicationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMedication()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func fetchMedication() {
        guard let requestURL = NSURL(string: "https://example.com/medications") else {
            return
        }

        let session = SeededURLSession.defaultSession()

        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "GET"

        session.dataTaskWithRequest(request, completionHandler: { [weak self] (data, response, error) -> Void in
            guard let weakSelf = self else { return }

            if let data = data, dict = weakSelf.parse(data),
              let medications = dict["medications"] as? [JSONDictionary],
              medication = medications.first {
                weakSelf.medicationLabel.text = medication["name"] as? String
            }

        }).resume()
    }

    typealias JSONDictionary = [String: AnyObject]

    func parse(data: NSData) -> JSONDictionary? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? JSONDictionary
        } catch let error {
            print(error)
        }
        return nil
    }

}

