//
//  EPHTTPTrackDownloadManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 11/02/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import Alamofire

class EPHTTPTrackDownloadManager {
    
    static let sharedInstance = EPHTTPTrackDownloadManager()

    fileprivate var requests = [Request]()

    fileprivate var downloadingTrackOperationMap = [EPTrack : Request]()
    
    class func downloadProgressForTrack(_ track: EPTrack) -> EPDownloadProgress? {
        
        for (trackEnum, _) in sharedInstance.downloadingTrackOperationMap {
            if track.uniqueID == trackEnum.uniqueID {
                if let downloadProgress = trackEnum.downloadProgress {
                    return downloadProgress
                }
            }
        }
        
        return nil
    }
    
    class func downloadTrack(_ track: EPTrack, completion: ((_ result:Bool, _ track:EPTrack) -> Void)?, progressBlock: ((_ progressValue: Double) -> Void)?) {
        print("downoadTrack called")
        
                //update track ID to match the one of the playlist, only then create a copy
                
                let trackCopy = track.copy() as! EPTrack
                
                for (trackEnum, _) in sharedInstance.downloadingTrackOperationMap {
                    if (trackCopy.ID == trackEnum.ID) {
                        print("track is already downloading")
                        return
                    }
                }

                let destination: DownloadRequest.DownloadFileDestination = { _, _ in

                    guard let fileURL = URL(string: EPCache.pathForTrackToSave(trackCopy)) else {
                        fatalError("unable to convert pathForTrackToSave into URL")
                    }

                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                }

                let downloadRequest = Alamofire.download(trackCopy.URLString, to: destination)

                downloadRequest.response(completionHandler: { (response) in

                    guard response.error == nil, let _ = response.destinationURL?.path else {

                        // handle failure

                        track.downloadProgress?.finished = false
                        track.downloadProgress = nil
                        completion?(false, trackCopy)
                        sharedInstance.downloadingTrackOperationMap.removeValue(forKey: track)

                        return
                    }

                    // update everyone else, track has been saved

                    sharedInstance.downloadingTrackOperationMap.removeValue(forKey: track)

                    track.downloadProgress?.finished = true
                    track.downloadProgress = nil

                    var fileSize: UInt64
                    let attr: NSDictionary? = try! FileManager.default.attributesOfItem(atPath: EPCache.pathForTrackToSave(trackCopy)) as NSDictionary?
                    if let _attr = attr {
                        fileSize = _attr.fileSize()
                        if fileSize > 0 && EPCache.addTrackToDownloadWithFileAtPath(trackCopy, filePath: EPCache.pathForTrackToSave(trackCopy)) {
                            print("file saved, size: \(fileSize)")
                            track.isCached = true
                            if completion != nil {
                                completion!(true, trackCopy)
                            }
                            return
                        } else {
                            if completion != nil {
                                completion!(false, trackCopy)
                            }
                        }

                    } else {
                        if completion != nil {
                            completion!(false, trackCopy)
                        }
                    }

                })

                track.downloadProgress = EPDownloadProgress()
                sharedInstance.downloadingTrackOperationMap[track] = downloadRequest

                downloadRequest.downloadProgress(closure: { (progress) in

                    track.downloadProgress?.percentComplete = progress.fractionCompleted
                    progressBlock?(progress.fractionCompleted)

                })

                downloadRequest.resume()
    }
    
    class func cancelTrackDownload(_ track:EPTrack) -> Bool {
        
        for (trackEnum, request) in sharedInstance.downloadingTrackOperationMap {
            if track.uniqueID == trackEnum.uniqueID {

                request.cancel()
                trackEnum.downloadProgress?.finished = false
                trackEnum.downloadProgress = nil
                sharedInstance.downloadingTrackOperationMap.removeValue(forKey: trackEnum)

                return true
            }
        }
        
        return false
    }
    
    class func cancelAllDownloads() {
        SessionManager.default.session.invalidateAndCancel()
    }
}
