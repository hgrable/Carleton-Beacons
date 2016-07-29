//
//  BeaconWebViewController.swift
//  Carleton-Beacons
//
//  Created by bilskys on 7/29/16.
//  Copyright © 2016 Carleton College. All rights reserved.
//

import UIKit

class BeaconWebViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var beaconInfoObj: BeaconInfo?
    
    override func viewDidLoad() {
        let url = beaconInfoObj?.url
        webView.loadRequest(NSURLRequest(URL: url!))
        
        self.title = beaconInfoObj?.title
    }
}
