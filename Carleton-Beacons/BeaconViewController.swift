//
//  BeaconViewController.swift
//  Blank
//
//  Created by bilskys on 7/5/16.
//  Copyright © 2016 Estimote, Inc. All rights reserved.
//

import UIKit

class BeaconViewController: UIViewController {
    
    var beaconID: String = String()
    
    //@IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backItem?.title = "Back"
        self.title = beaconID
        //titleLabel.text = beaconID
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}