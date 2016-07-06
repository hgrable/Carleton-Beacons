//
//  ViewController.swift
//  Blank
//

import UIKit

class ViewController: UIViewController, ESTBeaconManagerDelegate {

    let beaconManager = ESTBeaconManager()
    
    let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "70A27C24-0DD0-4C4F-99B2-3F642A998F27")!, identifier: "test")
    
    var beacons: [CLBeacon] = Array()
    
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
        if let name = self.namesByBeacons[beaconKey] {
            return name
        }
        return nil
    }
    
    func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        self.beacons = beacons
        
        var i = 1
        for beacon in beacons {
            if let name = nameOfBeacon(beacon) as String! {
                //print("\(i): \(name)")
                i += 1
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Beacon Table Segue" {
            if let dest = segue.destinationViewController as? BeaconTableViewController {
                dest.beacons = self.beacons
            }
        }
    }

}
