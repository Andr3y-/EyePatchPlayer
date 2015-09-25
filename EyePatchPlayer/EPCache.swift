//
//  EPCache.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 18/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

protocol EPCacheDelegate {
    func cacheDidUpdate()
}

class EPCache: NSObject {
    
    class func addTrackToDownloadWithFileAtPath(track:EPTrack, filePath: String) -> (Bool) {
        var result: Bool = false
        
        //check if already exists
        if checkTrackFileExistsInDownload(track) {
            //file already exists, handling
            
            let existingObjects = EPTrack.objectsWithPredicate(NSPredicate(format: "ID = %d", track.ID))
            
            if (existingObjects.count == 0) {
                //we're good to go
                
            } else if (existingObjects.count == 1){
                //object already cached and is contained now in existing objects
                //handle? perhaps, replace track with retrieved cached instance and return true
                
                return false
            } else {
                //existing objects count is neither 0 nor 1
                return false
            }
            
            
        }
        
        //if doesn't move file from old path to new path and record a result
        var error:NSError?
        let newPath:String = pathForTrackToSave(track)
        
        if newPath != filePath {
            
            //file needs to be moved to a right folder
            let moveResult = NSFileManager.defaultManager().moveItemAtPath(filePath, toPath: newPath, error: &error)
            
            if moveResult {
                
                //move was successful, file now exists at newPath
                
            } else {
                
                //move was unsuccessful, file doesn't exist at newPath, access error for more details
                
                if let unwrappedError = error {
                    
                    println("addTrackToCacheWithFileAtPath\nmoving file failed, error:\n\(unwrappedError.description)")
                    
                    return false
                }
            }
        }
        //create a new one now
        
        track.isCached = true
        track.URLString = newPath
        if let artworkToSave = track.artworkUIImage {
            println("artwork downloaded, trying to add to cache too")
            track.addArtworkImage(artworkToSave)

        } else {
            println("artwork is missing trying to download")
            EPHTTPManager.getAlbumCoverImage(track, completion: { (result, image) -> Void in
                if result {
                    track.addArtworkImage(image)
                }
            })
        }
        RLMRealm.defaultRealm().beginWriteTransaction()
        RLMRealm.defaultRealm().addOrUpdateObject(track)
        RLMRealm.defaultRealm().commitWriteTransaction()
        
        result = true
        NSNotificationCenter.defaultCenter().postNotificationName("TrackCached", object: track)
        println("added track to storage")
        
        return result
    }
    
    class func addTrackToDownloadWithFileData(track:EPTrack, data: NSData) -> (Bool) {
        var result: Bool = false
        
        //check if already exists,
        
        return result
    }
    
    class func deleteTrackFromDownload(track:EPTrack) -> (Bool) {
        var result: Bool = NSFileManager.defaultManager().removeItemAtPath(pathForTrackToSave(track), error: nil)
        var result2: Bool = NSFileManager.defaultManager().removeItemAtPath(pathForTrackArtwork(track), error: nil)
        
        if let trackRLM = trackCachedInstanceForTrack(track) {
            RLMRealm.defaultRealm().beginWriteTransaction()
            RLMRealm.defaultRealm().deleteObject(track)
            RLMRealm.defaultRealm().commitWriteTransaction()
        }
        
        return result
        //check if already exists,
    }
    
    class func trackCachedInstanceForTrack(track:EPTrack) -> (EPTrack)? {
        let existingObjects = EPTrack.objectsWithPredicate(NSPredicate(format: "ID = %d", track.ID))
//        println("existingObjects: \(existingObjects)")
        if (existingObjects.count == 0) {
            return nil
            
        } else if (existingObjects.count == 1){
            //object already cached and is contained now in existing objects
            //handle? perhaps, replace track with retrieved cached instance and return true
            let trackRLM: RLMObjectType? = existingObjects.firstObject()
            if let track: EPTrack = trackRLM as? EPTrack {
                println("trackCachedInstanceForTrack: \(track.artist) - \(track.title)\nlocated at: \(track.URL())")
                return track
            } else {
                return nil
            }
            
        } else {
            println("non unique result")
            return nil
        }
    }
    
    class func cacheStatusForTrack(track:EPTrack) -> (Bool) {
        if let trackInstance = trackCachedInstanceForTrack(track) {
            return true
        } else {
            return false
        }
    }
    
    class func artworkDirectory() -> (String) {
        let downloadPath = downloadDirectory()
        return downloadPath.stringByAppendingPathComponent("artwork")
    }
    
    class func downloadDirectory() -> (String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        return documentsPath.stringByAppendingPathComponent("download")
    }
    
    class func cacheDirectory() -> (String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        return documentsPath.stringByAppendingPathComponent("cache")
    }
    
    class func cacheEnabled() -> (Bool) {
        return true
    }
    
    class func maxDiskCacheSize() -> (Int) {
        return 100 * 1024 * 1024
    }

    class func performStartChecks() {
        println("EPCache perform start checks")
        EPCache.checkDirectoryExistsCreateIfNot(EPCache.downloadDirectory())
        EPCache.listFilesInDirectoryWithPath(EPCache.downloadDirectory())
        EPCache.checkDirectoryExistsCreateIfNot(EPCache.artworkDirectory())
        EPCache.listFilesInDirectoryWithPath(EPCache.artworkDirectory())
        EPCache.checkDirectoryExistsCreateIfNot(EPCache.cacheDirectory())
        EPCache.listFilesInDirectoryWithPath(EPCache.cacheDirectory())
    }
    
    class func checkDirectoryExistsCreateIfNot(path:String) {
        var isDir : ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory:&isDir) {
            // exists, no action needed
        } else {
            // file does not exist
            NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
    }
    
    
    class func checkTrackFileExistsInDownload(track:EPTrack) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(pathForTrackToSave(track))
    }
    
    
    class func pathForTrackToSave(track:EPTrack) -> (String) {
        return EPCache.downloadDirectory().stringByAppendingPathComponent("\(track.ID).mp3")
    }
    
    class func trackCoverImageIfExists(track:EPTrack) -> (UIImage?) {
        if let image = UIImage(contentsOfFile: pathForTrackArtwork(track)) {
            println("retrieving image for track \(track.artist) - \(track.title)")
            return image
        } else {
            return nil
        }
        
    }
    
    class func pathForTrackArtwork(track:EPTrack) -> (String) {
        return EPCache.downloadDirectory().stringByAppendingPathComponent("artwork").stringByAppendingPathComponent("\(track.ID).jpg")
    }
    
    class func listFilesInDirectoryWithPath (path:String) {
        println("listFilesInDirectoryWithPath: \(path)")
        let fileManager = NSFileManager.defaultManager()
        let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(path)!
        var count = 1
        var file: String
        
        for url in enumerator.allObjects {
            
            println("\(count) : \(url)")
            
            count++
        }
    }
}
