//
//  DataManager.swift
//  Carleton-Beacons
//
//  Created by Attila on 2015. 11. 10..
//  Copyright © 2015. -. All rights reserved.
//

import Foundation
import UIKit

//let BeaconInfoURL = "http://people.carleton.edu/~bilskys/beacons/beacons.json"

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

    public class func getBeaconInfoFromWebWithSuccess(url: NSURL, success: ((beaconInfo: NSData!) -> Void)) {
        //1
        loadDataFromURL(url, completion: { (data, error) -> Void in
            //2
            if let data = data {
                //3
                success(beaconInfo: data)
            }
        })
    }
    
    public class func getImageFromWebWithSuccess(url: NSURL, success: ((image: UIImage) -> Void)) {
        loadDataFromURL(url, completion: { (data, error) -> Void in
            if let data = data {
                if let image = UIImage(data: data) {
                    success(image: image)
                } else {
                    print("Error processing downloaded image")
                }
            } else {
                print("Error downloading image")
            }
        })
    }
    
    public class func parseJSONInfo(json: [String: AnyObject]) {
        // Parse beacon info from JSON file and save parsed data
        var beaconInfo: [String: BeaconInfo] = Dictionary()
        
        var newLastUpdatedDate: NSDate = NSDate(timeIntervalSince1970: 0)
        
        guard let metadata = json["metadata"] as? [String: AnyObject] else {
            print("Error serializing JSON metadata")
            return
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM-dd-yyyy-HH:mm"
        
        if let newLastUpdatedStr = metadata["last-updated"] as? String {
            newLastUpdatedDate = dateFormatter.dateFromString(newLastUpdatedStr)!
            print("New beacon info last updated at \(newLastUpdatedDate)")
        }
        
        if let oldLastUpdatedDate = NSKeyedUnarchiver.unarchiveObjectWithFile(BeaconInfo.LastUpdatedURL.path!) as? NSDate {
            print("Old beacon info last updated at \(oldLastUpdatedDate)")
            dateCompare: if newLastUpdatedDate.compare(oldLastUpdatedDate) != .OrderedDescending {
                print("No new beacon info")
                return
            } else {
                NSKeyedArchiver.archiveRootObject(newLastUpdatedDate, toFile: BeaconInfo.LastUpdatedURL.path!)
                print("Parsing new beacon info")
            }
        }
        
        guard let data = json["data"] as? [String: [String: AnyObject]] else {
            print("Error serializing JSON data")
            return
        }
        
        guard let allBeacons = data["beacons"] as? [String: [String: String]] else {
            print("Error serializing JSON data")
            return
        }
        
        for beacon in allBeacons {
            let beaconKey = beacon.0
            let beaconInfoDict = beacon.1
            
            let title = beaconInfoDict["title"]
            let subtitle = beaconInfoDict["subtitle"]
            let description = beaconInfoDict["description"]
            let image = beaconInfoDict["image"]
            let url = beaconInfoDict["url"]
            
            let beaconInfoObj = BeaconInfo(title: title, subtitle: subtitle, description: description, image: image, urlString: url)
            beaconInfo[beaconKey] = beaconInfoObj
        }
        // Persist dictionary of BeaconInfo objects
        let beaconInfoSaved = NSKeyedArchiver.archiveRootObject(beaconInfo, toFile: BeaconInfo.ArchiveURL.path!)
        print("Beacon info saved!")
        //print("Beacon info:")
        //print(beaconInfo)
        
        if !beaconInfoSaved {
            print("Error saving beacon info dictionary")
        }
    }
  
}
