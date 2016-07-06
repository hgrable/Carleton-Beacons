//
//  BeaconTableViewController.swift
//  Blank
//
//  Created by bilskys on 7/5/16.
//  Copyright © 2016 Estimote, Inc. All rights reserved.
//

import UIKit

class BeaconTableViewController: UITableViewController, ESTBeaconManagerDelegate {
    
    let beaconManager = ESTBeaconManager()
    
    let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "70A27C24-0DD0-4C4F-99B2-3F642A998F27")!, identifier: "test")
    
    var beacons: [CLBeacon] = Array()
    
    var beaconInfo: [String: BeaconInfo] = Dictionary()
    
    var beaconInfoByTableOrder: [BeaconInfo] = Array()
    
    var beaconInfoHasBeenLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.beaconManager.delegate = self
        
        self.beaconManager.requestWhenInUseAuthorization()
        
        getBeaconInfoFromWeb()
        beaconInfoHasBeenLoaded = true
    }
    
    override func viewWillAppear(animated: Bool) {
        // start ranging for beacons when app is launched
        super.viewWillAppear(animated)
        
        self.beaconManager.startRangingBeaconsInRegion(self.beaconRegion)
    }
    
    override func viewDidDisappear(animated: Bool) {
        // stop ranging for beacons when app is quit
        super.viewDidDisappear(animated)
        
        self.beaconManager.stopRangingBeaconsInRegion(self.beaconRegion)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
       
    func getBeaconInfoFromWeb() {
        DataManager.getBeaconInfoFromWebWithSuccess() { (jsonData) -> Void in
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
                if let data = json["data"] as? [String: [String: AnyObject]] {
                    if let allBeacons = data["beacons"] as? [String: [String: String]] {
                        var beaconInfo: [String: BeaconInfo] = Dictionary()
                        for beacon in allBeacons {
                            let beaconKey = beacon.0
                            let beaconInfoDict = beacon.1
                            let title = beaconInfoDict["title"]
                            let subtitle = beaconInfoDict["subtitle"]
                            let description = beaconInfoDict["description"]
                            let image = beaconInfoDict["image"]
                            let beaconInfoObj = BeaconInfo(title: title, subtitle: subtitle, description: description, image: image)
                            beaconInfo[beaconKey] = beaconInfoObj
                        }
                        self.beaconInfo = beaconInfo
                    }
                } else {
                    print("Error serializing JSON data")
                }
            } catch {
                print(error)
            }
        }
    }
    
    func getBeaconInfoFromBeacon(beacon: CLBeacon) -> BeaconInfo {
        let beaconKey = "\(beacon.major):\(beacon.minor)"
        let beaconInfoObj = beaconInfo[beaconKey]!
        return beaconInfoObj
    }
    
    func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        self.beacons = beacons
        
        var beaconInfoByTableOrder: [BeaconInfo] = Array()
        
        if beaconInfoHasBeenLoaded {
            for beacon in beacons {
                let beaconInfoObj = getBeaconInfoFromBeacon(beacon)
                beaconInfoByTableOrder.append(beaconInfoObj)
            }
        }
        self.beaconInfoByTableOrder = beaconInfoByTableOrder
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconInfoByTableOrder.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Basic")!
        
        cell.textLabel?.text = beaconInfoByTableOrder[indexPath.row].title
        cell.textLabel?.contentScaleFactor
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        cell.detailTextLabel?.text = beaconInfoByTableOrder[indexPath.row].subtitle
        cell.detailTextLabel?.minimumScaleFactor = 0
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
        let image = UIImage(named: "beacon")!
        cell.imageView?.image = image
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Beacon Segue" {
            let selectedRow = tableView.indexPathForSelectedRow?.row
            
            if let dest = segue.destinationViewController as? BeaconViewController {
                dest.beaconTitle = beaconInfoByTableOrder[selectedRow!].title
            }
        }
    }
}