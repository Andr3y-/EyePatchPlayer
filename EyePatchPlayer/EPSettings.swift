//
//  EPSettings.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 23/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

enum EPArtworkSize {
    case Small
    case Medium
    case Large
}

class EPSettings: NSUserDefaults {
    class func shouldBroadcastStatus() -> (Bool) {
        //read from NSUserDefaults()
        return true
    }
    
    class func shoulScrobbleWithLastFm() -> (Bool) {
        //read from NSUserDefaults()
        return true
    }
    
    class func shouldDownloadArtwork() -> (Bool) {
        //read from NSUserDefaults()
        return true
    }
    
    class func preferredArtworkSizeString() -> String {
        switch EPSettings.preferredArtworkSizeEnum() {
        case .Small:
            return "200x200"
            
        case .Medium:
            return "400x400"
            
        case .Large:
            return "600x600"
        }
    }
    
    private class func preferredArtworkSizeEnum() -> EPArtworkSize {
        //read from NSUserDefaults()
        return .Large
    }
}
