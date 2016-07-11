//
//  BeaconInfo.swift
//  Carleton-Beacons
//
//  Created by bilskys on 7/6/16.
//  Copyright © 2016 Carleton College. All rights reserved.
//

class BeaconInfo: NSObject, NSCoding {
    
    var title: String = ""
    var subtitle: String = ""
    var descriptionText: String = ""
    var image: String = ""
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("beacons")
    static let LastUpdatedURL = DocumentsDirectory.URLByAppendingPathComponent("lastUpdated")
    
    init(title: String?, subtitle: String?, description: String?, image: String?) {
        if title != nil {
            self.title = title!
        }
        if subtitle != nil {
            self.subtitle = subtitle!
        }
        if description != nil {
            self.descriptionText = description!
        }
        if image != nil {
            self.image = image!
        }
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: PropertyKey.titleKey)
        aCoder.encodeObject(subtitle, forKey: PropertyKey.subtitleKey)
        aCoder.encodeObject(descriptionText, forKey: PropertyKey.descriptionKey)
        aCoder.encodeObject(image, forKey: PropertyKey.imageKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let title = aDecoder.decodeObjectForKey(PropertyKey.titleKey) as! String
        let subtitle = aDecoder.decodeObjectForKey(PropertyKey.subtitleKey) as! String
        let descriptionText = aDecoder.decodeObjectForKey(PropertyKey.descriptionKey) as! String
        let image = aDecoder.decodeObjectForKey(PropertyKey.imageKey) as! String
        self.init(title: title, subtitle: subtitle, description: descriptionText, image: image)
    }
}

struct PropertyKey {
    static let titleKey = "title"
    static let subtitleKey = "subtitle"
    static let descriptionKey = "description"
    static let imageKey = "imageKey"
}