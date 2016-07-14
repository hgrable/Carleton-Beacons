//
//  BeaconTableViewController.swift
//  Carleton-Beacons
//
//  Created by bilskys on 7/5/16.
//  Copyright © 2016 Estimote, Inc. All rights reserved.
//

import UIKit
import Foundation

class BeaconTableViewController: UITableViewController, ESTBeaconManagerDelegate {
    
    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var activityIndicator = UIActivityIndicatorView()
    
    let beaconManager = ESTBeaconManager()
    
    let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "70A27C24-0DD0-4C4F-99B2-3F642A998F27")!, identifier: "test")
    
    var beaconInfo: [String: BeaconInfo] = Dictionary()
    
    var beaconInfoByTableOrder: [BeaconInfo] = Array()
    
    override func viewDidLoad() {
        self.beaconManager.delegate = self
        
        self.beaconManager.requestWhenInUseAuthorization()
        
        self.preferredStatusBarStyle()
        
        // Set navigation bar style
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 39.0/255.0, blue: 118.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "TrebuchetMS-Bold", size:18)!]
        
        self.beaconInfo = Dictionary()
        
        getBeaconInfo() { (dataHasBeenLoaded) -> Void in
            if dataHasBeenLoaded {
                // print("Stopping activity indicator")
                // self.activityIndicator.stopAnimating()
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
    
    func showActivityIndicator() {
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 290, y: 290, width: 40, height: 40))
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
    }

    func getBeaconInfo(completion: (dataHasBeenLoaded: Bool) -> Void) {
        // Download JSON file containing beacon info
        let infoJSONUrl = NSURL(string: "http://people.carleton.edu/~bilskys/beacons/beacons.json")!
        
        var json: [String: AnyObject] = Dictionary()
        
        DataManager.getBeaconInfoFromWebWithSuccess(infoJSONUrl) { (jsonData) -> Void in
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
    
    func loadBeaconInfo() {
        self.beaconInfo = NSKeyedUnarchiver.unarchiveObjectWithFile(BeaconInfo.ArchiveURL.path!) as! [String: BeaconInfo]
        print("Beacon info loaded!")
    }
    
    func getBeaconInfoForBeacon(beacon: CLBeacon) -> BeaconInfo? {
        let beaconKey = "\(beacon.major):\(beacon.minor)"
        let beaconInfoObj = self.beaconInfo[beaconKey] as BeaconInfo!
        return beaconInfoObj
    }

    func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        var beaconInfoByTableOrder: [BeaconInfo] = Array()
        
        // Make sure that we have at least as many beacon info objects as beacons in range
        guard self.beaconInfo.count >= beacons.count else {
                print("No beacon info yet")
                return
            }
        
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconInfoByTableOrder.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Basic")!
        
        let imageView = cell.viewWithTag(101) as! UIImageView
        let titleLabel = cell.viewWithTag(102) as! UILabel
        let subtitleLabel = cell.viewWithTag(103) as! UILabel
        
        titleLabel.font = UIFont(name: "TrebuchetMS-Bold", size: 20)
        titleLabel.text = beaconInfoByTableOrder[indexPath.row].title
        subtitleLabel.text = beaconInfoByTableOrder[indexPath.row].subtitle
        
        if let image = beaconInfoByTableOrder[indexPath.row].imageThumb {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let selectedRow = tableView.indexPathForSelectedRow?.row
        
        if let dest = segue.destinationViewController as? BeaconViewController {
            dest.beaconInfoObj = beaconInfoByTableOrder[selectedRow!]
        }
    }
}