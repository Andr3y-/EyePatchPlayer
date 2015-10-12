//
//  IntTimeToString.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 09/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import Foundation

extension Int {
    
    func timeInSecondsToString() -> String {
        
        let minutes = (self % 3600 / 60) < 10 ? NSString(format: "0%d", self % 3600 / 60) : NSString(format: "%d", self % 3600 / 60)
        let seconds = (self % 3600 % 60) < 10 ? NSString(format: "0%d", self % 3600 % 60) : NSString(format: "%d", self % 3600 % 60)
        
        return NSString(format: "%@:%@", minutes, seconds) as String
    }
    
}