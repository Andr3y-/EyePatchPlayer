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
            let moveResult: Bool
            do {
                try NSFileManager.defaultManager().moveItemAtPath(filePath, toPath: newPath)
                moveResult = true
            } catch let error1 as NSError {
                error = error1
                moveResult = false
            }
            
            if moveResult {
                
                //move was successful, file now exists at newPath
                
            } else {
                
                //move was unsuccessful, file doesn't exist at newPath, access error for more details
                
                if let unwrappedError = error {
                    
                    print("addTrackToCacheWithFileAtPath\nmoving file failed, error:\n\(unwrappedError.description)")
                    
                    return false
                }
            }
        }
        //create a new one now
        
        track.isCached = true
        track.URLString = newPath
        if let artworkToSave = track.artworkUIImage {
            print("artwork downloaded, trying to add to cache too")
            track.addArtworkImage(artworkToSave)

        } else {
            print("artwork is missing trying to download")
            EPHTTPManager.getAlbumCoverImage(track, completion: { (result, image, trackID) -> Void in
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
        print("added track to storage")
        
        return result
    }
    
    class func addTrackToDownloadWithFileData(track:EPTrack, data: NSData) -> (Bool) {
        let result: Bool = false
        
        //check if already exists,
        
        return result
    }
    
    class func deleteTrackFromDownload(track:EPTrack) -> (Bool) {
        var result: Bool
        do {
            try NSFileManager.defaultManager().removeItemAtPath(pathForTrackToSave(track))
            result = true
        } catch _ {
            result = false
        }
//        var result2: Bool
        do {
            try NSFileManager.defaultManager().removeItemAtPath(pathForTrackArtwork(track))
//            result2 = true
        } catch _ {
//            result2 = false
        }
        
        if let _ = trackCachedInstanceForTrack(track) {
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
            let trackRLM: RLMObject? = existingObjects.firstObject()
            if let track: EPTrack = trackRLM as? EPTrack {
                print("trackCachedInstanceForTrack: \(track.artist) - \(track.title)\nlocated at: \(track.URL())")
                return track
            } else {
                return nil
            }
            
        } else {
            print("non unique result")
            return nil
        }
    }
    
    class func cacheStatusForTrack(track:EPTrack) -> (Bool) {
        if let _ = trackCachedInstanceForTrack(track) {
            return true
        } else {
            return false
        }
    }
    
    class func artworkDirectory() -> (String) {
        let downloadPath = downloadDirectory()
        return (downloadPath as NSString).stringByAppendingPathComponent("artwork")
    }
    
    class func downloadDirectory() -> (String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        return documentsPath.stringByAppendingPathComponent("download")
    }
    
    class func cacheDirectory() -> (String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        return documentsPath.stringByAppendingPathComponent("cache")
    }
    
    class func cacheEnabled() -> (Bool) {
        return true
    }
    
    class func maxDiskCacheSize() -> (Int) {
        return 100 * 1024 * 1024
    }

    class func performStartChecks() {
        print("EPCache perform start checks")
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
            do {
                // file does not exist
                try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
    }
    
    
    class func checkTrackFileExistsInDownload(track:EPTrack) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(pathForTrackToSave(track))
    }
    
    
    class func pathForTrackToSave(track:EPTrack) -> (String) {
        return (EPCache.downloadDirectory() as NSString).stringByAppendingPathComponent("\(track.ID).mp3")
    }
    
    class func trackCoverImageIfExists(track:EPTrack) -> (UIImage?) {
        if let image = UIImage(contentsOfFile: pathForTrackArtwork(track)) {
            print("retrieving image for track \(track.artist) - \(track.title)")
            return image
        } else {
            return nil
        }
        
    }
    
    class func pathForTrackArtwork(track:EPTrack) -> (String) {
        return ((EPCache.downloadDirectory() as NSString).stringByAppendingPathComponent("artwork") as NSString).stringByAppendingPathComponent("\(track.ID).jpg")
    }
    
    class func listFilesInDirectoryWithPath (path:String) {
        print("listFilesInDirectoryWithPath: \(path)")
        let fileManager = NSFileManager.defaultManager()
        let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(path)!
        var count = 1
        
        for url in enumerator.allObjects {
            
            print("\(count) : \(url)")
            
            count++
        }
    }
}
