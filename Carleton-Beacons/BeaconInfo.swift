//
//  BeaconInfo.swift
//  Carleton-Beacons
//
//  Created by bilskys on 7/6/16.
//  Copyright © 2016 Carleton College. All rights reserved.
//

struct BeaconInfo {
    
    var title: String = ""
    var subtitle: String = ""
    var description: String = ""
    var image: String = ""
    
    init(title: String?, subtitle: String?, description: String?, image: String?) {
        if title != nil {
            self.title = title!
        }
        if subtitle != nil {
            self.subtitle = subtitle!
        }
        if description != nil {
            self.description = description!
        }
        if image != nil {
            self.image = image!
        }
    }
}
