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
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.title = beaconInfoObj?.title
        
        self.subtitleLabel.text = beaconInfoObj?.subtitle
        self.subtitleLabel.font = UIFont(name: "TrebuchetMS", size: 18)
        
        self.descriptionText.text = beaconInfoObj?.descriptionText
        self.descriptionText.textContainer.lineFragmentPadding = 0
        
        self.imageView.image = beaconInfoObj?.imageFull
    }
    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
}