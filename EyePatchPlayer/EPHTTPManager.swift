//
//  EPHTTPManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 24/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPHTTPManager: NSObject {
    
    static let sharedInstance = EPHTTPManager()

    var downloadingTracks = NSMutableArray()
    
    class func downloadTrack(track: EPTrack, completion: ((result : Bool, track: EPTrack) -> Void)?, progressBlock: ((progressValue: Float) -> Void)?) {
        println("downoadTrack called")
        
        var trackCopy = track.copy() as! EPTrack
        
        for trackEnum in EPHTTPManager.sharedInstance.downloadingTracks {
            if (trackCopy.ID == trackEnum.ID) {
                println("track is already downloading")
                return
            }
        }
        
        EPHTTPManager.sharedInstance.downloadingTracks.addObject(track)
        var downloadOperation = AFHTTPRequestOperationManager().GET(trackCopy.URLString, parameters: nil, success: { (operation, responseObject) -> Void in
            println("download successful")
            
            EPHTTPManager.sharedInstance.downloadingTracks.removeObject(track)
            
            var fileSize : UInt64
            var attr:NSDictionary? = NSFileManager.defaultManager().attributesOfItemAtPath(EPCache.pathForTrackToSave(trackCopy), error: nil)
            if let _attr = attr {
                fileSize = _attr.fileSize()
                if fileSize > 0 && EPCache.addTrackToDownloadWithFileAtPath(trackCopy, filePath: EPCache.pathForTrackToSave(trackCopy)) {
                    println("file saved, size: \(fileSize)")
                    track.isCached = true
                    if completion != nil {
                        completion! (result: true, track: trackCopy)
                    }
                    return
                } else {
                    if completion != nil {
                        completion! (result: false, track: trackCopy)
                    }
                }
                
            } else {
                if completion != nil {
                    completion! (result: false, track: trackCopy)
                }
            }
            
            
        }) { (operation, responseObject) -> Void in
            println("download unsuccessful")
            if completion != nil {
                completion! (result: false, track: trackCopy)
            }
            EPHTTPManager.sharedInstance.downloadingTracks.removeObject(track)
        }
        downloadOperation?.outputStream = NSOutputStream(toFileAtPath: EPCache.pathForTrackToSave(trackCopy), append: false)
        downloadOperation?.outputStream?.open()
        downloadOperation?.setDownloadProgressBlock({ (written, totalWritten, totalExpected) -> Void in
            let progress:Float = Float(totalWritten) / Float(totalExpected)
            if progressBlock != nil {
                progressBlock! (progressValue: progress)
            }
            
//            println("download: \(progress)%\n\(written) | \(totalWritten) | \(totalExpected)")
        })
        downloadOperation?.resume()
        
        if downloadOperation != nil && downloadOperation?.isPaused() == false {
            println("download started")
        } else {
            println("download failed to start")
        }
    }

    class func getAlbumCoverImage(track: EPTrack, completion: ((result : Bool, image:UIImage, trackID: Int) -> Void)?) {
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        let parameters = "\(track.title) \(track.artist)"
        manager.GET("https://itunes.apple.com/search", parameters: ["term" : parameters], success: { (operation, response) -> Void in
            println(response)
            if let searchResults:AnyObject = response["results"] {
                if let searchResultsArray: NSArray = searchResults as? NSArray {
                    if let resultsDict: AnyObject = searchResultsArray.firstObject {
                        if let resultsDictCast: NSDictionary = resultsDict as? NSDictionary {
                            if let URLString100x100 = resultsDictCast["artworkUrl100"] as? NSString {
                                var url = NSURL(string: URLString100x100.stringByReplacingOccurrencesOfString("100x100", withString: EPSettings.preferredArtworkSizeString()))
                                println(url)
                                SDWebImageManager.sharedManager().downloadImageWithURL(url, options: nil, progress: nil, completed: { (downloadedImage:UIImage!, error:NSError!, cacheType:SDImageCacheType, isDownloaded:Bool, withURL:NSURL!) -> Void in
                                    if isDownloaded {
                                        track.addArtworkImage(downloadedImage)
                                        if completion != nil {
                                            completion! (result: true, image: downloadedImage, trackID: track.ID)
                                        }
                                        return
                                    } else {
                                        if completion != nil {
                                            completion! (result: false, image: UIImage(), trackID: track.ID)
                                        }
                                    }
                                    
                                })
                            }
                        }
                    } else {
                        println("no results for album artwork")
                    }
                }
            }
            
            if completion != nil {
                completion! (result: false, image: UIImage(),trackID: track.ID)
            }
            }) { (opeation, error) -> Void in
                println("album art iTunes request failed")
                if completion != nil {
                    completion! (result: false, image: UIImage(),trackID: track.ID)
                }
        }
    }
}
