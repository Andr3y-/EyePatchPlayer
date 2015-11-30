//
//  EPHTTPManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 24/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk
import AFNetworking
import SDWebImage
import CryptoSwift

class EPHTTPManager: NSObject {

    static let sharedInstance = EPHTTPManager()
    private static let lastfmAPIRoot = "https://ws.audioscrobbler.com/2.0/"
    let tracksDownloadManager = AFHTTPRequestOperationManager()
    let artworkDownloadManager = AFHTTPRequestOperationManager()
    let lastfmManager = AFHTTPRequestOperationManager()

    var maxSimultaneousDownloads = 3
//    var queuedTracks = NSMutableArray()
    var downloadingTracks = NSMutableArray()

    override init() {
        super.init()
        tracksDownloadManager.operationQueue.maxConcurrentOperationCount = 2
        artworkDownloadManager.responseSerializer = AFJSONResponseSerializer()
        lastfmManager.responseSerializer = AFJSONResponseSerializer()
        lastfmManager.operationQueue.maxConcurrentOperationCount = 3
    }

    class func downloadProgressForTrack(track: EPTrack) -> EPDownloadProgress? {
        for trackObject in EPHTTPManager.sharedInstance.downloadingTracks {
            let trackInArray = trackObject as! EPTrack
            if track.ID == trackInArray.ID {
                if let downloadProgress = trackInArray.downloadProgress {
                    return downloadProgress
                }
            }
        }
        return nil
    }

    class func VKGetLastAudiosFromMessages(count: Int, intermediateResultBlock: ((track:EPTrack) -> Void)?, completion: ((result:Bool, tracks:[EPTrack]?) -> Void)?) {
        if let _ = VKSdk.getAccessToken().userId {
            print("VKGetLastAudiosFromMessages request")

            let messagesPerRequestCount = 200
            let currentOffset = 0

            EPHTTPManager.VKGETAudiosFromMessagesWithCountOffset(count, messagesPerRequestCount: messagesPerRequestCount, offset: currentOffset, tracksArray: [EPTrack](), intermediateCompletion: intermediateResultBlock, finalCompletion: {
                (tracks) -> Void in
                print("tracks parsed: \(tracks.count)")
                if completion != nil {
                    completion!(result: count >= tracks.count, tracks: tracks)
                }
            })

        } else {
            print("VKGetLastAudiosFromMessages: could not resolve VK UserID")

            if completion != nil {
                completion!(result: false, tracks: nil)
            }
        }
    }

    private class func VKGETAudiosFromMessagesWithCountOffset(requiredCount: Int, messagesPerRequestCount: Int, offset: Int, var tracksArray: [EPTrack], intermediateCompletion: ((track:EPTrack) -> Void)?, finalCompletion: ((tracks:[EPTrack]) -> Void)?) {
        print("VKGETAudiosFromMessagesWithCount: \(requiredCount) Offset: \(offset) CurrentTracksCount: \(tracksArray.count)")

        let addRequest: VKRequest = VKRequest(method: "messages.get", andParameters: ["count": "\(messagesPerRequestCount)", "offset": "\(offset)"], andHttpMethod: "GET")
        addRequest.executeWithResultBlock({
            (response) -> Void in
            if let messagesArray = (response.json as! NSDictionary)["items"] as? [NSDictionary] {
                for messageJSON in messagesArray {
                    let message = EPMessage(response: messageJSON)
                    if let messageAttachments = message.attachments {
                        for attachment in messageAttachments {
                            if attachment.type == AttachmentType.Audio {
                                if let track = attachment.object as? EPTrack {

                                    tracksArray.append(track)
                                    print("track parsed")
                                    if intermediateCompletion != nil {
                                        intermediateCompletion!(track: track)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                print("messagesArray none")
            }

            if tracksArray.count >= requiredCount {
                print("enough tracks parsed: \(tracksArray.count)")
                if finalCompletion != nil {
                    finalCompletion!(tracks: tracksArray)
                }
                return
            } else {
                EPHTTPManager.VKGETAudiosFromMessagesWithCountOffset(requiredCount, messagesPerRequestCount: messagesPerRequestCount, offset: offset + messagesPerRequestCount, tracksArray: tracksArray, intermediateCompletion: intermediateCompletion, finalCompletion: finalCompletion)
            }

        }, errorBlock: {
            (error) -> Void in

            print(error)
        })
    }

    class func VKBroadcastTrack(track: EPTrack) {
//        print("broadcasting track")
        if !AFNetworkReachabilityManager.sharedManager().reachable {
            return
        }
        let broadcastRequest: VKRequest = VKRequest(method: "audio.setBroadcast", andParameters: ["audio": "\(track.ownerID)_\(track.ID)"], andHttpMethod: "GET")
        broadcastRequest.executeWithResultBlock({
            (response) -> Void in
            print("broadcasting track success result: \(response.json)")
        }, errorBlock: {
            (error) -> Void in
            print(error)
        })
    }

    class func VKTrackAddToPlaylistIfNeeded(track: EPTrack, completion: ((result:Bool, track:EPTrack?) -> Void)?) {
        print("adding track to playlist")

        if !EPSettings.shouldAutomaticallySaveToPlaylist() {
            if completion != nil {
                completion!(result: false, track: track)
            }
        }

        if let userID = VKSdk.getAccessToken().userId {

            if userID == "\(track.ownerID)" {
                //track already in the playlist
                print("adding track to playlist success result: track is already in the playlist")
                if completion != nil {
                    completion!(result: true, track: track)
                }
            } else {
                //track is not in the playlist, adding it
                let addRequest: VKRequest = VKRequest(method: "audio.add", andParameters: ["audio_id": "\(track.ID)", "owner_id": track.ownerID], andHttpMethod: "GET")
                addRequest.executeWithResultBlock({
                    (response) -> Void in

                    let newID = response.json as! Int

                    print("adding track to playlist success result: \(newID)")
                    //update track ID
                    track.ID = newID

                    if completion != nil {
                        completion!(result: true, track: track)
                    }

                }, errorBlock: {
                    (error) -> Void in
                    if completion != nil {
                        completion!(result: false, track: nil)
                    }

                    print(error)
                })
            }

        } else {
            print("adding track to playlist success result: could not resolve VK UserID")

            if completion != nil {
                completion!(result: false, track: nil)
            }
        }
    }


    class func retrievePlaylistOfUserWithID(userID: Int?, count: Int?, completion: ((result:Bool, playlist:EPMusicPlaylist?) -> Void)?) {
        var specificUserID = 3677921

        if let userID = userID {
            //Specified UserID exists, OK
            specificUserID = userID
            print("loading playlist for user with id \(userID)")

        } else {
            if let token = VKSdk.getAccessToken() {
                if let userID = token.userId {
                    //VK UserID exists, OK
                    specificUserID = Int(userID)!
                    print("default playlist for logged in user with id \(userID)")
                } else {

                }
            }

        }

        let audioRequest: VKRequest = VKRequest(method: "audio.get", andParameters: [VK_API_OWNER_ID: specificUserID, VK_API_COUNT: count != nil ? count! : 2000, "need_user": 0], andHttpMethod: "GET")

        audioRequest.executeWithResultBlock({
            (response) -> Void in

            let playlist = EPMusicPlaylist.initWithResponse(response.json as! NSDictionary)

            if completion != nil {
                completion!(result: true, playlist: playlist)
            }

        }, errorBlock: {
            (error) -> Void in
            if completion != nil {
                completion!(result: false, playlist: nil)
            }
        })
    }

    class func lastfmBroadcastTrack(track: EPTrack, completion: ((result:Bool) -> Void)?) {
        if EPSettings.lastfmMobileSession().characters.count < 1 || !AFNetworkReachabilityManager.sharedManager().reachable {
            return
        }

        let scrobble = EPLastFMScrobble(track: track)
        let parameters =
        [
                "method": "track.updateNowPlaying",
                "artist": scrobble.artist,
                "track": scrobble.track,
                "api_key": EPConstantsClass.LastfmAPIKey,
                "duration": String(scrobble.duration),
                "sk": EPSettings.lastfmMobileSession()
        ]

        guard let URL = self.lastfmURLStringForMethod(parameters) else {
            if completion != nil {
                completion!(result: false)
            }
            return
        }

        sharedInstance.lastfmManager.POST(URL, parameters: nil, success: {
            (operation, response) -> Void in
            print("lastfm track.updateNowPlaying success")
            if completion != nil {
                completion!(result: true)
            }
        }) {
            (operation, error) -> Void in
            print("lastfm track.updateNowPlaying failure")
            print(operation.response)
            if completion != nil {
                completion!(result: false)
            }
        }
    }

    class func lastfmScrobbleTrack(scrobble: EPLastFMScrobble, completion: ((result:Bool) -> Void)?) {
        let parameters =
        [
                "method": "track.scrobble",
                "artist": scrobble.artist,
                "track": scrobble.track,
                "api_key": EPConstantsClass.LastfmAPIKey,
                "timestamp": String(scrobble.timestamp),
                "duration": String(scrobble.duration),
                "sk": EPSettings.lastfmMobileSession()
        ]

        guard let URL = self.lastfmURLStringForMethod(parameters) else {
            if completion != nil {
                completion!(result: false)
            }
            return
        }

        sharedInstance.lastfmManager.POST(URL, parameters: nil, success: {
            (operation, response) -> Void in
            print("lastfm scrobbling success")
            if completion != nil {
                completion!(result: true)
            }
        }) {
            (operation, error: NSError) -> Void in
            if let data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? NSData {
                if let errorResponse = String(data: data, encoding: NSUTF8StringEncoding) {
                    print("lastfm scrobbling failure:\ncode:\(error.code)\nresponse:\(errorResponse)")
                    if completion != nil {
                        completion!(result: false)
                    }
                    return
                }
            }
            print("lastfm scrobbling failure:\ncode:\(error.code)\nresponse: no data")
            if completion != nil {
                completion!(result: false)
            }
            return
        }
    }

    class func lastfmAuthenticate(username: String, password: String, completion: ((result:Bool, session:String) -> Void)?) {
        print("lastfmAuthenticate initiated")
        let parameters =
        [
                "method": "auth.getMobileSession",
                "username": username,
                "password": password,
                "api_key": EPConstantsClass.LastfmAPIKey

        ]

        guard let URL = self.lastfmURLStringForMethod(parameters) else {
            if completion != nil {
                completion!(result: false, session: "")
            }
            return
        }
        sharedInstance.lastfmManager.POST(URL, parameters: nil, success: {
            (operation, response) -> Void in
            print("lastfm auth success: \(response)")
            if let sessionObject: AnyObject = response["session"] {
                if let sessionDictionary = sessionObject as? [String:AnyObject] {
                    if let sessionKey = sessionDictionary["key"] as? String {
                        if completion != nil {
                            completion!(result: true, session: sessionKey)
                        }
                    }
                }
            }

        }) {
            (operation, error: NSError) -> Void in
            print("lastfm auth failure:\ncode:\(error.code)")
            if completion != nil {
                completion!(result: false, session: "")
            }
        }
    }

    private class func lastfmURLStringForMethod(parameters: [String:String]) -> String? {
        var URL = "\(lastfmAPIRoot)?"
        for (key, value) in parameters {

            URL.appendContentsOf(key)
            URL.appendContentsOf("=")
            if let clearedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) {
                URL.appendContentsOf(clearedValue.stringByReplacingOccurrencesOfString("&", withString: "%26"))
            } else {
                return nil
            }
            URL.appendContentsOf("&")
        }
        guard let api_sig = self.lastfmMethodSignature(parameters) else {
            return nil
        }
        URL.appendContentsOf("api_sig=")
        URL.appendContentsOf(api_sig)
        URL.appendContentsOf("&format=json")
//        print("URL to sign: \(URL)")
        return URL
    }

    private class func lastfmMethodSignature(parameters: [String:String]) -> String? {
        //sort abc...xyz
        let parametersSorted = parameters.keys.sort()
        var rawSignature = ""
        //construct rawSignature step 1
        for key in parametersSorted {
            rawSignature.appendContentsOf(key)
            guard let appendingValue = parameters[key] else {
                return nil
            }
            rawSignature.appendContentsOf(appendingValue)
        }
        //construct rawSignature step 2
        rawSignature.appendContentsOf(EPConstantsClass.LastfmSecret)
        //construction complete, return md5
//        print("signature: \(rawSignature)")
//        print("md5 sign:  \(rawSignature.md5())")
        return rawSignature.md5()
    }

    class func downloadTrack(track: EPTrack, completion: ((result:Bool, track:EPTrack) -> Void)?, progressBlock: ((progressValue:Float) -> Void)?) {
        print("downoadTrack called")

        EPHTTPManager.VKTrackAddToPlaylistIfNeeded(track, completion: {
            (result, newTrack) -> Void in
            //download with adding to playlist first
            if let track = newTrack {
                //update track ID to match the one of the playlist, only then create a copy

                let trackCopy = track.copy() as! EPTrack

                for trackEnum in EPHTTPManager.sharedInstance.downloadingTracks {
                    if (trackCopy.ID == trackEnum.ID) {
                        print("track is already downloading")
                        return
                    }
                }

                EPHTTPManager.sharedInstance.downloadingTracks.addObject(track)
                track.downloadProgress = EPDownloadProgress()

                let downloadOperation = sharedInstance.tracksDownloadManager.GET(trackCopy.URLString, parameters: nil, success: {
                    (operation, responseObject) -> Void in
                    print("download successful")

                    EPHTTPManager.sharedInstance.downloadingTracks.removeObject(track)
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
                    EPHTTPManager.sharedInstance.downloadingTracks.removeObject(track)
                    track.downloadProgress?.finished = false
                    track.downloadProgress = nil
                    if completion != nil {
                        completion!(result: false, track: trackCopy)
                    }
                    EPHTTPManager.sharedInstance.downloadingTracks.removeObject(track)
                }
                downloadOperation?.outputStream = NSOutputStream(toFileAtPath: EPCache.pathForTrackToSave(trackCopy), append: false)
                downloadOperation?.outputStream?.open()
                downloadOperation?.setDownloadProgressBlock({
                    (written, totalWritten, totalExpected) -> Void in
                    let progress: Float = Float(totalWritten) / Float(totalExpected)

                    if let downloadProgress = track.downloadProgress {
                        downloadProgress.percentComplete = progress
                    }

                    if progressBlock != nil {
                        progressBlock!(progressValue: progress)
                    }

                    //            println("download: \(progress)%\n\(written) | \(totalWritten) | \(totalExpected)")
                })
                downloadOperation?.resume()

                if downloadOperation != nil && downloadOperation?.isPaused() == false {
                    print("download started")
                } else {
                    print("download failed to start")
                }
            }
        })
    }

    class func getAlbumCoverImage(track: EPTrack, completion: ((result:Bool, image:UIImage, trackID:Int) -> Void)?) {
        sharedInstance.artworkDownloadManager.operationQueue.cancelAllOperations()

        let searchQuery = EPArtworkSearchQueryFilter.searchQueryForTrack(track)
        sharedInstance.artworkDownloadManager.GET("https://itunes.apple.com/search", parameters: ["term": searchQuery], success: {
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
                                        completion!(result: false, image: UIImage(), trackID: track.ID)
                                    }
                                    return
                                }
                                print(url)
                                SDWebImageManager.sharedManager().downloadImageWithURL(url, options: [], progress: nil, completed: {
                                    (downloadedImage: UIImage!, error: NSError!, cacheType: SDImageCacheType, isDownloaded: Bool, withURL: NSURL!) -> Void in
                                    if isDownloaded && downloadedImage != nil {
                                        track.addArtworkImage(downloadedImage)
                                        if completion != nil {
                                            completion!(result: true, image: downloadedImage, trackID: track.ID)
                                        }
                                        return
                                    } else {
                                        print("album art iTunes request failed (no image downloaded)")
                                        if completion != nil {
                                            completion!(result: false, image: UIImage(), trackID: track.ID)
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
                    completion!(result: false, image: UIImage(), trackID: track.ID)
                }
            }
        }) {
            (opeation, error) -> Void in
            print("album art iTunes request failed (request failure)")
            if completion != nil {
                completion!(result: false, image: UIImage(), trackID: track.ID)
            }
        }
    }

    class func getLyricsForTrack(track: EPTrack, completion: ((result:Bool, lyrics:EPLyrics?, trackID:Int) -> Void)?) {

        print("checking lyrics for track")
        let trackID = track.ID
        let trackDetailsRequest: VKRequest = VKRequest(method: "audio.getById", andParameters: ["audios": "\(track.ownerID)_\(track.ID)"], andHttpMethod: "GET")
        trackDetailsRequest.executeWithResultBlock({
            (response) -> Void in
            print(response)
            if let responseArray = response.json as? [NSDictionary] {
                if responseArray.count < 1 {
                    if completion != nil {
                        completion!(result: false, lyrics: nil, trackID: trackID)
                    }
                    return
                }
                let downloadedTrack = EPTrack.initWithResponse(responseArray.first!)
                if let lyricsID = downloadedTrack.lyricsID {
                    let lyricsRequest: VKRequest = VKRequest(method: "audio.getLyrics", andParameters: ["lyrics_id": "\(lyricsID)"], andHttpMethod: "GET")
                    lyricsRequest.executeWithResultBlock({
                        (response) -> Void in
                        if let responseDictionary = response.json as? NSDictionary {
                            let lyrics = EPLyrics(dictionary: responseDictionary)
                            if completion != nil {
                                completion!(result: true, lyrics: lyrics, trackID: trackID)
                            }
                            return
                        }
                        return
                    }, errorBlock: {
                        (error) -> Void in

                    })
                } else {
                    if completion != nil {
                        completion!(result: false, lyrics: nil, trackID: trackID)
                    }
                    return
                }
            } else {
                if completion != nil {
                    completion!(result: false, lyrics: nil, trackID: trackID)
                }
                return
            }

        }, errorBlock: {
            (error) -> Void in
            if completion != nil {
                completion!(result: false, lyrics: nil, trackID: trackID)
            }
            return
        })
    }
}











