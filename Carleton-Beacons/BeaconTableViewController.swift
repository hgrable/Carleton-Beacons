//
//  BeaconTableViewController.swift
//  Carleton-Beacons
//
//  Created by bilskys on 7/5/16.
//  Copyright © 2016 Estimote, Inc. All rights reserved.
//

import UIKit
import Foundation

class BeaconTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ESTBeaconManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let beaconManager = ESTBeaconManager()
    
    let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "AD54EAF7-D4D4-4598-A635-BE547BB98C63")!, major: 1866, identifier: "test")
    
    var beaconInfo: [String: BeaconInfo] = Dictionary()
    
    var beaconInfoByTableOrder: [BeaconInfo] = Array()
    
    override func viewDidLoad() {
        self.beaconManager.delegate = self
        
        // Ask user to authorize location services when the app is in use
        self.beaconManager.requestWhenInUseAuthorization()
        
        // Set navigation bar style
        self.preferredStatusBarStyle()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 39.0/255.0, blue: 118.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 20)!]
        self.navigationController?.navigationBar.topItem!.title = "Exhibits Near You"
        
        // Set up the UITableView as a subview of this view controller
        tableView.delegate = self
        tableView.dataSource = self
        
        // Retrieve beacon attributes
        self.beaconInfo = Dictionary()
        getBeaconInfo() { (dataHasBeenLoaded) -> Void in }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        // Set the status bar style to light content so that it's readable against the blue navigation bar
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        // Start ranging for beacons when app is launched
        super.viewWillAppear(animated)
        
        self.beaconManager.startRangingBeaconsInRegion(self.beaconRegion)
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Stop ranging for beacons when app is quit
        super.viewDidDisappear(animated)
        
        self.beaconManager.stopRangingBeaconsInRegion(self.beaconRegion)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Communicates with the server to check for updated beacon info, and download it if found
    func getBeaconInfo(completion: (dataHasBeenLoaded: Bool) -> Void) {
        
        // Location of beacon info JSON
        let infoJSONUrl = NSURL(string: "http://people.carleton.edu/~bilskys/beacons/beacons.json")!
        
        var json: [String: AnyObject] = Dictionary()
        
        // Asynchronously download beacon info JSON, parse into a Swift dictionary, save, and load into memory
        DataManager.getBeaconInfoFromWebWithSuccess(infoJSONUrl) { (jsonData) -> Void in
            // Once the data is downloaded, do the parsing and saving and loading stuff
            do {
                json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as! [String : AnyObject]
                DataManager.parseJSONInfo(json)
                self.loadBeaconInfo()
                completion(dataHasBeenLoaded: true)
            } catch {
                print(error)
                completion(dataHasBeenLoaded: false)
            }
        }
    }
    
    // Loads archived dictionary of BeaconInfo objects
    func loadBeaconInfo() {
        self.beaconInfo = NSKeyedUnarchiver.unarchiveObjectWithFile(BeaconInfo.ArchiveURL.path!) as! [String: BeaconInfo]
    }
    
    // Helper function; looks up a BeaconInfo object using the minor value of the given beacon
    func getBeaconInfoForBeacon(beacon: CLBeacon) -> BeaconInfo? {
        let beaconKey = "\(beacon.minor)"
        let beaconInfoObj = self.beaconInfo[beaconKey] as BeaconInfo!
        return beaconInfoObj
    }

    // The beaconManager function runs more or less continuously to update the beacons that are visible to the phone.
    func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        var beaconInfoByTableOrder: [BeaconInfo] = Array()
        
        // Make sure that we have at least as many beacon info objects as beacons in range
        guard self.beaconInfo.count >= beacons.count else {
                print("No beacon info yet")
                return
            }
        
        // The beaconInfoByTableOrder array will be used as the data source for the table.
        // We only want to add beacons to it with a minimum level of signal strength, a.k.a maximum distance.
        // The beacons list is already ordered by approximate distance, so beaconInfoByTableOrder will be too.
        for beacon in beacons {
            // RSSI = Received Signal Strength Indicator (dBs)
            // -85 dBs corresponds to about 10 feet away
            if beacon.rssi >= -85 {
                let beaconInfoObj = getBeaconInfoForBeacon(beacon)
                beaconInfoByTableOrder.append(beaconInfoObj!)
            }
        }
        
        self.beaconInfoByTableOrder = beaconInfoByTableOrder
        
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconInfoByTableOrder.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Basic", forIndexPath: indexPath) as UITableViewCell
        let row = indexPath.row
        
        // Connect title, subtitle, and image subviews
        let titleLabel = cell.contentView.viewWithTag(101) as! UILabel
        let subtitleLabel = cell.contentView.viewWithTag(102) as! UILabel
        let imageView = cell.contentView.viewWithTag(103) as! UIImageView

        // Set cell title
        titleLabel.font = UIFont(name: "TrebuchetMS", size: 20)
        titleLabel.text = beaconInfoByTableOrder[row].title
        
        // Set cell subtitle
        subtitleLabel.font = UIFont(name: "TrebuchetMS", size: 14)
        subtitleLabel.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        subtitleLabel.text = beaconInfoByTableOrder[row].subtitle
        
        // Set cell image (placeholder if imageThumb doesn't exist)
        if let image = beaconInfoByTableOrder[row].imageThumb {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Send beacon information to detail view when user taps on a cell in the table
        if segue.identifier == "BeaconWebSegue" {
            
            let row = tableView.indexPathForSelectedRow?.row
            
            if let dest = segue.destinationViewController as? BeaconWebViewController {
                dest.beaconInfoObj = beaconInfoByTableOrder[row!]
            }
        }
    }
}