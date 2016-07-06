//
//  BeaconTableViewController.swift
//  Blank
//
//  Created by bilskys on 7/5/16.
//  Copyright © 2016 Estimote, Inc. All rights reserved.
//

import UIKit
import Gloss

class BeaconTableViewController: UITableViewController, ESTBeaconManagerDelegate {
    
    let beaconManager = ESTBeaconManager()
    
    let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "70A27C24-0DD0-4C4F-99B2-3F642A998F27")!, identifier: "test")
    
    var beacons: [CLBeacon] = Array()
    
    var beaconNames: [String] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.beaconManager.delegate = self
        
        self.beaconManager.requestWhenInUseAuthorization()
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
    
    let namesByBeacons = [
        "1000:456":  "Light Blue",
        "123:789":   "Light Green",
        "786:50787": "Purple"
    ]
    
    func nameOfBeacon(beacon: CLBeacon) -> String? {
        let beaconKey = "\(beacon.major):\(beacon.minor)"
        
        let url = NSURL(string: "http://people.carleton.edu/~bilskys/beacons/beacons.json")!
        NSURLSession.sharedSession().dataTaskWithURL(url) { json, response, error in
            let error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            
            if (json != nil) {
                
                struct BeaconInfo: Decodable {
                    
                    let title: String?
                    let subtitle: String?
                    let description: String?
                    let image: String?
                    
                    init?(json: JSON) {
                        self.title = "title" <~~ json
                        self.subtitle = "subtitle" <~~ json
                        self.description = "description" <~~ json
                        self.image = "image" <~~ json
                    }
                
                }
            } else {
                print(error)
            }
        }.resume()
        
        if let name = self.namesByBeacons[beaconKey] {
            return name
        }
        
        return nil
    }
    
    func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        self.beacons = beacons
        
        var names: [String] = Array()
        
        for beacon in beacons {
            if let name = nameOfBeacon(beacon) as String! {
                names.append(name)
            }
        }
        
        self.beaconNames = names
        
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Basic")!
        
        cell.textLabel?.text = beaconNames[indexPath.row]
        cell.textLabel?.contentScaleFactor
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        cell.detailTextLabel?.text = "Lorem ipsum blah blah blah"
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
                dest.beaconID = beaconNames[selectedRow!]
            }
        }
    }
}