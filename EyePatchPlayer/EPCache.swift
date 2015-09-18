//
//  EPCache.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 18/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPCache: NSObject {
    
    class func cacheDirectory() -> (String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        return documentsPath.stringByAppendingPathComponent("cache")
    }
    
    class func downloadDirectory() -> (String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        return documentsPath.stringByAppendingPathComponent("download")
    }
    
    class func cacheEnabled() -> (Bool) {
        return true
    }
    
    class func maxDiskCacheSize() -> (Int) {
        return 100 * 1024 * 1024
    }

    class func performStartChecks() {
        println("EPCache perform start checks")
        EPCache.checkDownloadDirectory()
        EPCache.checkCacheDirectory()
    }
    
    class func checkDownloadDirectory() {
        EPCache.checkDirectoryExistsCreateIfNot(EPCache.downloadDirectory())
        EPCache.listFilesInDirectoryWithPath(EPCache.downloadDirectory())
    }
    
    class func checkCacheDirectory() {
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
    
    class func listFilesInDirectoryWithPath (path:String) {
        println("listFilesInDirectoryWithPath: \(path)")
        let fileManager = NSFileManager.defaultManager()
        let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(path)!
        var count = 1
        var file: String
        
        for url in enumerator.allObjects {
            
            println("\(count) : \(url)")
//            let fileAttributes:NSDictionary = NSFileManager.defaultManager().attributesOfItemAtPath(url as! String, error: nil)!
//            println("size: \(fileAttributes[NSFileSize] as! CLongLong)")
            count++
        }
    }
    
    class func pathForTrackToSave(track:EPTrack) -> (String) {
        return EPCache.cacheDirectory().stringByAppendingPathComponent("\(track.artist) - \(track.title) - \(track.ID).mp3")
    }
}
