//
//  EPSettings.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 23/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPSettings: NSUserDefaults {
    class func shouldBroadcastStatus() -> (Bool) {
        return true
    }
    
    class func shoulScrobbleWithLastFm() -> (Bool) {
        return true
    }
}
