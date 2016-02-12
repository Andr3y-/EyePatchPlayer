//
//  IntTimeToString.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 09/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import Foundation

extension Int {

    var durationString: String {
        if self > 60 * 60 {
            
            let minutes: NSString = (self % 3600 / 60) < 10 ? NSString(format: "0%d", self % 3600 / 60) : NSString(format: "%d", self % 3600 / 60)
            let seconds: NSString = (self % 3600 % 60) < 10 ? NSString(format: "0%d", self % 3600 % 60) : NSString(format: "%d", self % 3600 % 60)
            let hours: NSString = (self / 3600) < 10 ? NSString(format: "0%d", self / 3600) : NSString(format: "%d", self / 3600)
            
            return NSString(format: "%@:%@:%@", hours, minutes, seconds) as String
        } else {
            
            let minutes: NSString = (self % 3600 / 60) < 10 ? NSString(format: "0%d", self % 3600 / 60) : NSString(format: "%d", self % 3600 / 60)
            let seconds: NSString = (self % 3600 % 60) < 10 ? NSString(format: "0%d", self % 3600 % 60) : NSString(format: "%d", self % 3600 % 60)
            
            return NSString(format: "%@:%@", minutes, seconds) as String
        }
    }
}
