//
//  DataManager.swift
//  TopApps
//
//  Created by Attila on 2015. 11. 10..
//  Copyright © 2015. -. All rights reserved.
//

import Foundation

let BeaconInfoURL = "http://people.carleton.edu/~bilskys/beacons/beacons.json"

public class DataManager {
  
    public class func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.URLCache = nil
        let session = NSURLSession(configuration: configuration)
        
        let loadDataTask = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                  let statusError = NSError(domain:"com.simonbr", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                  completion(data: nil, error: statusError)
                } else {
                  completion(data: data, error: nil)
                }
            }
        }
        loadDataTask.resume()
    }

    public class func getBeaconInfoFromWebWithSuccess(success: ((BeaconInfo: NSData!) -> Void)) {
        //1
        loadDataFromURL(NSURL(string: BeaconInfoURL)!, completion:{(data, error) -> Void in
            //2
            if let data = data {
                //3
                success(BeaconInfo: data)
            }
        })
    }
  
}
