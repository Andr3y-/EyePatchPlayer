//
//  EPMusicItem.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPTrack: NSObject {
    
    var title: String = ""
    var artist: String = ""
    var ownerID: Int = 0
    var duration: Int = 0
    var ID: Int = 0
    var URL: NSURL = NSURL()
    var isCached = false
    
    class func initWithResponse(response: NSDictionary) -> EPTrack {
        var track = EPTrack()
        
//        println("EPTrack: initWithResponse\n\(response)")
        
        track.title = response["title"] as! String
        track.artist = response["artist"] as! String
        track.duration = response["duration"] as! Int
        track.ownerID = response["owner_id"] as! Int
        track.ID = response["id"] as! Int
        track.URL = NSURL(string: response["url"] as! String)!
        
//        println("EPTrack: initWithResponse finish")
        
        return track
    }
}
