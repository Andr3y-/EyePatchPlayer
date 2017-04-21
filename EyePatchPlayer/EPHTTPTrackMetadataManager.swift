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
    
    fileprivate static var artworkDownloadManager: AFHTTPRequestOperationManager = {
        var manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        return manager
    }()
    
    class func getAlbumCoverImage(_ track: EPTrack, completion: ((_ result:Bool, _ image:UIImage, _ trackUniqueID:String) -> Void)?) {
        artworkDownloadManager.operationQueue.cancelAllOperations()
        
        let searchQuery = EPArtworkSearchQueryFilter.searchQueryForTrack(track)
        
        //  keeping ID separately to limit references to track itself, which can become invalidated
        let trackUniqueID = track.uniqueID
        
        artworkDownloadManager.get("https://itunes.apple.com/search", parameters: ["term": searchQuery], success: {
            (operation, response) -> Void in

            guard let response = response as? [String: AnyObject] else {
                fatalError()
            }

            if let searchResults: AnyObject = response["results"] {
                if let searchResultsArray: NSArray = searchResults as? NSArray {
                    if let resultsDict: AnyObject = searchResultsArray.firstObject as AnyObject? {
                        if let resultsDictCast: NSDictionary = resultsDict as? NSDictionary {
                            if let URLString100x100 = resultsDictCast["artworkUrl100"] as? NSString {
                                guard let url = URL(string: URLString100x100.replacingOccurrences(of: "100x100", with: EPSettings.preferredArtworkSizeString())) else {
                                    print("album art iTunes request failed (url is null)")
                                    if completion != nil {
                                        completion!(false, UIImage(), trackUniqueID)
                                    }
                                    return
                                }
                                print(url)

                                SDWebImageManager.shared().downloadImage(with: url, options: [], progress: nil, completed: { (downloadedImage, error, cacheType, isDownloaded, withURL) in

                                    if isDownloaded && downloadedImage != nil {
                                        
                                        if !track.isInvalidated {
                                            track.addArtworkImage(downloadedImage!)
                                        }
                                        
                                        if completion != nil {
                                            completion!(true, downloadedImage!, trackUniqueID)
                                        }
                                        
                                        return
                                    } else {
                                        print("album art iTunes request failed (no image downloaded)")
                                        if completion != nil {
                                            completion!(false, UIImage(), trackUniqueID)
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
                    completion!(false, UIImage(), trackUniqueID)
                }
            }
            }) {
                (opeation, error) -> Void in
                print("album art iTunes request failed (request failure)")
                if completion != nil {
                    completion!(false, UIImage(), trackUniqueID)
                }
        }
    }
}
