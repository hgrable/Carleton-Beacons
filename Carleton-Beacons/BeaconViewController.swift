//
//  BeaconViewController.swift
//  Blank
//
//  Created by bilskys on 7/5/16.
//  Copyright © 2016 Estimote, Inc. All rights reserved.
//

import UIKit

class BeaconViewController: UIViewController {
    
    var beaconTitle: String = String()
    
    //@IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change back button text to "Back"
        self.navigationController?.navigationBar.topItem?.title = "Back"
        
        self.title = beaconTitle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}