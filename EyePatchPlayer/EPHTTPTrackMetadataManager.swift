//
//  EPHTTPTrackMetadataManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 11/02/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage

class EPHTTPTrackMetadataManager: NSObject {
    
    private static var artworkDownloadManager: AFHTTPRequestOperationManager = {
        var manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        return manager
    }()
    
    class func getAlbumCoverImage(track: EPTrack, completion: ((result:Bool, image:UIImage, trackID:Int) -> Void)?) {
        artworkDownloadManager.operationQueue.cancelAllOperations()
        
        let searchQuery = EPArtworkSearchQueryFilter.searchQueryForTrack(track)
        
        //  keeping ID separately to limit references to track itself, which can become invalidated
        let trackID = track.ID
        
        artworkDownloadManager.GET("https://itunes.apple.com/search", parameters: ["term": searchQuery], success: {
            (operation, response) -> Void in
            //            print(response)
            if let searchResults: AnyObject = response["results"] {
                if let searchResultsArray: NSArray = searchResults as? NSArray {
                    if let resultsDict: AnyObject = searchResultsArray.firstObject {
                        if let resultsDictCast: NSDictionary = resultsDict as? NSDictionary {
                            if let URLString100x100 = resultsDictCast["artworkUrl100"] as? NSString {
                                guard let url = NSURL(string: URLString100x100.stringByReplacingOccurrencesOfString("100x100", withString: EPSettings.preferredArtworkSizeString())) else {
                                    print("album art iTunes request failed (url is null)")
                                    if completion != nil {
                                        completion!(result: false, image: UIImage(), trackID: trackID)
                                    }
                                    return
                                }
                                print(url)
                                SDWebImageManager.sharedManager().downloadImageWithURL(url, options: [], progress: nil, completed: {
                                    (downloadedImage: UIImage!, error: NSError!, cacheType: SDImageCacheType, isDownloaded: Bool, withURL: NSURL!) -> Void in
                                    if isDownloaded && downloadedImage != nil {
                                        
                                        if !track.invalidated {
                                            track.addArtworkImage(downloadedImage)
                                        }
                                        
                                        if completion != nil {
                                            completion!(result: true, image: downloadedImage, trackID: trackID)
                                        }
                                        
                                        return
                                    } else {
                                        print("album art iTunes request failed (no image downloaded)")
                                        if completion != nil {
                                            completion!(result: false, image: UIImage(), trackID: trackID)
                                        }
                                    }
                                    
                                })
                            }
                        }
                    } else {
                        
                        print("no results for album artwork for query: \(searchQuery)\nfull query:\nhttps://itunes.apple.com/search?term=\(searchQuery)\noperation.request:\n\(operation.request.description)\nraw response:\n\(response)")
                    }
                }
            } else {
                print("album art iTunes request failed (no search results received)")
                if completion != nil {
                    completion!(result: false, image: UIImage(), trackID: trackID)
                }
            }
            }) {
                (opeation, error) -> Void in
                print("album art iTunes request failed (request failure)")
                if completion != nil {
                    completion!(result: false, image: UIImage(), trackID: trackID)
                }
        }
    }
}
