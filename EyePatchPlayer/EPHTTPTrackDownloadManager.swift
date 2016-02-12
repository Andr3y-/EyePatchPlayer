//
//  EPHTTPTrackDownloadManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 11/02/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import AFNetworking

class EPHTTPTrackDownloadManager: AFHTTPRequestOperationManager {
    
    static let sharedInstance = EPHTTPTrackDownloadManager()
//    private var downloadingTracks = NSMutableArray()
    private var operations = [AFHTTPRequestOperation]()
    
    private var downloadingTrackOperationMap = [EPTrack : AFHTTPRequestOperation]()
    
    override init(baseURL url: NSURL?) {
        super.init(baseURL: url)
        self.responseSerializer = AFJSONResponseSerializer()
        self.operationQueue.maxConcurrentOperationCount = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func downloadProgressForTrack(track: EPTrack) -> EPDownloadProgress? {
        
        for (trackEnum, _) in sharedInstance.downloadingTrackOperationMap {
            if track.ID == trackEnum.ID {
                if let downloadProgress = trackEnum.downloadProgress {
                    return downloadProgress
                }
            }
        }
        
        return nil
    }
    
    class func downloadTrack(track: EPTrack, completion: ((result:Bool, track:EPTrack) -> Void)?, progressBlock: ((progressValue:Float) -> Void)?) {
        print("downoadTrack called")
        
        EPHTTPVKManager.addTrackToPlaylistIfNeeded(track, completion: {
            (result, newTrack) -> Void in
            //download with adding to playlist first
            if let track = newTrack {
                //update track ID to match the one of the playlist, only then create a copy
                
                let trackCopy = track.copy() as! EPTrack
                
                for (trackEnum, _) in sharedInstance.downloadingTrackOperationMap {
                    if (trackCopy.ID == trackEnum.ID) {
                        print("track is already downloading")
                        return
                    }
                }

                let downloadOperationObject = sharedInstance.GET(trackCopy.URLString, parameters: nil, success: {
                    (operation, responseObject) -> Void in
                    print("download successful")
                    
                    sharedInstance.downloadingTrackOperationMap.removeValueForKey(track)

                    track.downloadProgress?.finished = true
                    track.downloadProgress = nil
                    
                    var fileSize: UInt64
                    let attr: NSDictionary? = try? NSFileManager.defaultManager().attributesOfItemAtPath(EPCache.pathForTrackToSave(trackCopy))
                    if let _attr = attr {
                        fileSize = _attr.fileSize()
                        if fileSize > 0 && EPCache.addTrackToDownloadWithFileAtPath(trackCopy, filePath: EPCache.pathForTrackToSave(trackCopy)) {
                            print("file saved, size: \(fileSize)")
                            track.isCached = true
                            if completion != nil {
                                completion!(result: true, track: trackCopy)
                            }
                            return
                        } else {
                            if completion != nil {
                                completion!(result: false, track: trackCopy)
                            }
                        }
                        
                    } else {
                        if completion != nil {
                            completion!(result: false, track: trackCopy)
                        }
                    }
                    
                    
                    }) {
                        (operation, responseObject) -> Void in
                        print("download unsuccessful")
                        sharedInstance.downloadingTrackOperationMap.removeValueForKey(track)
                        track.downloadProgress?.finished = false
                        track.downloadProgress = nil
                        if completion != nil {
                            completion!(result: false, track: trackCopy)
                        }
                        sharedInstance.downloadingTrackOperationMap.removeValueForKey(track)

                    } as AFHTTPRequestOperation?
                
                guard let downloadOperation = downloadOperationObject else {
                    print("download operation failed to init")
                    return
                }
                
                //  Created Operation, now add it to the list
                track.downloadProgress = EPDownloadProgress()
                sharedInstance.downloadingTrackOperationMap[track] = downloadOperation
                
                downloadOperation.setShouldExecuteAsBackgroundTaskWithExpirationHandler({ () -> Void in
                    print("track download expired in background: \(trackCopy.artist) - \(trackCopy.title)")
                })
                
                downloadOperation.outputStream = NSOutputStream(toFileAtPath: EPCache.pathForTrackToSave(trackCopy), append: false)
                downloadOperation.outputStream?.open()
                downloadOperation.setDownloadProgressBlock({
                    (written, totalWritten, totalExpected) -> Void in
                    let progress: Float = Float(totalWritten) / Float(totalExpected)
                    
                    if let downloadProgress = track.downloadProgress {
                        downloadProgress.percentComplete = progress
                    }
                    
                    if progressBlock != nil {
                        progressBlock!(progressValue: progress)
                    }
                })
                downloadOperation.resume()
                
                if downloadOperation.isPaused() == false {
                    print("download started")
                } else {
                    print("download failed to start")
                }
            }
        })
    }
    
    class func cancelTrackDownload(track:EPTrack) -> Bool {
        
        for (trackEnum, operation) in sharedInstance.downloadingTrackOperationMap {
            if track.ID == trackEnum.ID {
                operation.cancel()
                return true
            }
        }
        
        return false
    }
}
