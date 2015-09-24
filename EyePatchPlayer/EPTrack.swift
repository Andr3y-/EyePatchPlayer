//
//  EPMusicItem.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit


class EPTrack: RLMObject {
    
    dynamic var title: String = ""
    dynamic var artist: String = ""
    dynamic var ownerID: Int = 0
    dynamic var duration: Int = 0
    dynamic var ID: Int = 0
    dynamic var URLString: String = ""
    dynamic var isCached = false
    
    class func initWithResponse(response: NSDictionary) -> EPTrack {
        var track = EPTrack()
        
//        println("EPTrack: initWithResponse\n\(response)")
        
        track.title = response["title"] as! String
        track.artist = response["artist"] as! String
        track.duration = response["duration"] as! Int
        track.ownerID = response["owner_id"] as! Int
        track.ID = response["id"] as! Int
        track.URLString = response["url"] as! String
        
//        println("EPTrack: initWithResponse finish")
        
        return track
    }
    
    func hasFileAtPath() -> Bool {
        var result = NSFileManager.defaultManager().fileExistsAtPath(self.URL().path!)
        var error: NSError?
        if let attr:NSDictionary = NSFileManager.defaultManager().attributesOfItemAtPath(self.URL().path!, error: &error) {
            println("fileSize: \(attr.fileSize())")
        } else {
            println("unable to retrieve a fileSize, \(error?.description)")
        }
        return result
    }
    
    func URL() -> NSURL {
        if (isCached){
            return NSURL(fileURLWithPath: EPCache.pathForTrackToSave(self))!
        } else {
            return NSURL(string: URLString)!
        }
    
    }
    
//    class func initWithEPRLMTrack(RLMTrack:EPRLMTrack) -> EPTrack {
//        var track = EPTrack()
//        
//        track.title = RLMTrack.title
//        track.artist = RLMTrack.artist
//        track.duration = RLMTrack.duration
//        
//        return track
//    }
    

}
