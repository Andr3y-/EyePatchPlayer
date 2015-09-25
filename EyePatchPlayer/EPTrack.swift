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
    private dynamic var isArtworkCached = false
    
    var artworkUIImage: UIImage?
    
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
    
    func artworkImage() -> UIImage? {
        
        if (self.artworkUIImage != nil) {
            return self.artworkUIImage
        } else if self.isCached && self.isArtworkCached {
            if let artworkImage = EPCache.trackCoverImageIfExists(self) {
                self.artworkUIImage = artworkImage
                return self.artworkUIImage
            }

        }
        return nil
    }
    
    func clearArtworkImage() {
        println("clearArtworkImage - \(self.title)")
        self.artworkUIImage = nil
    }
    
    func addArtworkImage(image:UIImage) {
        self.artworkUIImage = image
        
        if self.isCached && !self.isArtworkCached {
            let artworkImageData = UIImageJPEGRepresentation(image, 1.0)
            println(EPCache.pathForTrackArtwork(self))
            if artworkImageData.writeToFile(EPCache.pathForTrackArtwork(self), atomically: true) {
                println("caching artwork for cached track")
                RLMRealm.defaultRealm().beginWriteTransaction()
                self.isArtworkCached = true
                RLMRealm.defaultRealm().addOrUpdateObject(self)
                RLMRealm.defaultRealm().commitWriteTransaction()
            } else {
                println("failed to cache artwork")
            }
            
        } else {

        }
    }
    
    func URL() -> NSURL {
        if (isCached){
            return NSURL(fileURLWithPath: EPCache.pathForTrackToSave(self))!
        } else {
            return NSURL(string: URLString)!
        }
    
    }
    
    override func copy() -> AnyObject {
        var track = EPTrack()
        
        track.title = self.title
        track.artist = self.artist
        track.duration = self.duration
        track.ownerID = self.ownerID
        track.ID = self.ID
        track.URLString = self.URLString
        track.isCached = self.isCached
        
        return track
    }
    
    override class func ignoredProperties() -> [AnyObject]? {
        return ["artworkUIImage"]
    }
    
    override class func primaryKey() -> String {
        return "ID"
    }
}
