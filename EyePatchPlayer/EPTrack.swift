//
//  EPMusicItem.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import Realm

class EPTrack: RLMObject {

    dynamic var title: String = ""
    dynamic var artist: String = ""
    dynamic var ownerID: Int = 0
    dynamic var duration: Int = 0
    dynamic var ID: Int = 0
    dynamic var URLString: String = ""
    dynamic var isCached = false
    
    var uniqueID:String {
        return "\(ownerID)_\(ID)"
    }
    //  KVO pair
    private dynamic var isArtworkCached = false
    internal dynamic var downloadProgress: EPDownloadProgress?
    
    var lyricsID: Int?
    var artworkUIImage: UIImage?

    class func initWithResponse(response: NSDictionary) -> EPTrack {
        let track = EPTrack()

        track.title = response["title"] as! String
        track.artist = response["artist"] as! String
        track.duration = response["duration"] as! Int
        track.ownerID = response["owner_id"] as! Int
        track.ID = response["id"] as! Int
        track.URLString = response["url"] as! String
        track.isCached = EPCache.cacheStatusForTrack(track)
        if let lyricsID = response["lyrics_id"] as? Int {
            track.lyricsID = lyricsID
        }
        return track
    }

    func hasFileAtPath() -> Bool {
        let result = NSFileManager.defaultManager().fileExistsAtPath(self.URL().path!)
        var error: NSError?
        do {
            let attr: NSDictionary = try NSFileManager.defaultManager().attributesOfItemAtPath(self.URL().path!)
            print("fileSize: \(attr.fileSize())")
        } catch let error1 as NSError {
            error = error1
            print("unable to retrieve a fileSize, \(error?.description)")
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
        print("clearArtworkImage - \(self.title)")
        self.artworkUIImage = nil
    }

    func addArtworkImage(image: UIImage) {
        self.artworkUIImage = image

        if self.isCached && !self.isArtworkCached {
            
            guard let artworkImageData = UIImageJPEGRepresentation(image, 1.0) else {
                print("Failed to cache artwork UIImageJPEGRepresentation nil")
                return
            }
            
            let artworkSavePath = (EPCache.pathForTrackArtwork(self))
            
            print("Attempting to cache artwork at:\n\(artworkSavePath)")
            
            if artworkImageData.writeToFile(artworkSavePath, atomically: true) {
                
                print("caching artwork for cached track")
                
                if self.observationInfo != nil {
                    print("track observation info is non-nil, however addOrUpdateObject is called")
                    if let selfCopy = self.copy() as? EPTrack {

                        do {
                            RLMRealm.defaultRealm().beginWriteTransaction()
                            selfCopy.isArtworkCached = true
                            RLMRealm.defaultRealm().addOrUpdateObject(selfCopy)
                            try RLMRealm.defaultRealm().commitWriteTransaction()

                        } catch {

                        }

                        
                    }
                    
                } else {

                    do {
                        RLMRealm.defaultRealm().beginWriteTransaction()
                        self.isArtworkCached = true
                        RLMRealm.defaultRealm().addOrUpdateObject(self)
                        try RLMRealm.defaultRealm().commitWriteTransaction()
                        
                    } catch {
                        
                    }
                }

            } else {
                print("failed to cache artwork")
            }

        } else {

        }
    }

    func URL() -> NSURL {
        if (isCached) {
            return NSURL(fileURLWithPath: EPCache.pathForTrackToSave(self))
        } else {
            return NSURL(string: URLString)!
        }

    }

    override func copy() -> AnyObject {
        let track = EPTrack()

        track.title = self.title
        track.artist = self.artist
        track.duration = self.duration
        track.ownerID = self.ownerID
        track.ID = self.ID
        track.URLString = self.URLString
        track.isCached = self.isCached
        track.lyricsID = self.lyricsID
        track.artworkUIImage = self.artworkUIImage
        
        return track
    }
    
    override static func ignoredProperties() -> [String] {
        return ["artworkUIImage", "downloadProgress", "lyricsID", "uniqueID"]
    }

    override static func primaryKey() -> String {
        return "ID"
    }
    
    class func defaultTrack() -> EPTrack {
        let track = EPTrack()
        
        track.title = "Let It Be"
        track.artist = "The Beatles"
        track.duration = 243
        track.ownerID = 3677921
        track.ID = 96332345
        track.URLString = "https://psv4.vk.me/c4536/u116195/audios/6bbca7b17bd9.mp3?extra=AJ8ypzFNOCJJY5tJ3vxeDUwNOyejIK0kwWLljK1qNwQLOnhcjFdo_MPZrqXKxEGV5bzTujCGSLHuElG1jO10aUOnwbI"
        track.isCached = EPCache.cacheStatusForTrack(track)
        track.lyricsID = 8876171
        
        return track
    }
}
