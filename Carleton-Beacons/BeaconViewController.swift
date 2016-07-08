//
//  BeaconViewController.swift
//  Carleton-Beacons
//
//  Created by bilskys on 7/5/16.
//  Copyright © 2016 Estimote, Inc. All rights reserved.
//

import UIKit

class BeaconViewController: UIViewController {
    
    var beaconInfoObj: BeaconInfo?
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var descriptionText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change back button text to "Back"
        self.navigationController?.navigationBar.topItem?.title = "Back"
        
        self.title = beaconInfoObj?.title
        self.subtitleLabel.text = beaconInfoObj?.subtitle
        self.descriptionText.text = beaconInfoObj?.descriptionText
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}