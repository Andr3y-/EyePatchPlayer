//
//  EPHTTPVKManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 11/02/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import VK_ios_sdk
import AFNetworking

class EPHTTPVKManager: NSObject {
    
    class func getLastAudiosFromMessages(count: Int, intermediateResultBlock: ((track:EPTrack) -> Void)?, completion: ((result:Bool, tracks:[EPTrack]?) -> Void)?) {
        if let _ = VKSdk.getAccessToken().userId {
            print("VKGetLastAudiosFromMessages request")
            
            let messagesPerRequestCount = 200
            let currentOffset = 0
            
            EPHTTPVKManager.getAudiosFromMessagesWithCountOffset(count, messagesPerRequestCount: messagesPerRequestCount, offset: currentOffset, tracksArray: [EPTrack](), intermediateCompletion: intermediateResultBlock, finalCompletion: {
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
    
    private class func getAudiosFromMessagesWithCountOffset(requiredCount: Int, messagesPerRequestCount: Int, offset: Int, var tracksArray: [EPTrack], intermediateCompletion: ((track:EPTrack) -> Void)?, finalCompletion: ((tracks:[EPTrack]) -> Void)?) {
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
                EPHTTPVKManager.getAudiosFromMessagesWithCountOffset(requiredCount, messagesPerRequestCount: messagesPerRequestCount, offset: offset + messagesPerRequestCount, tracksArray: tracksArray, intermediateCompletion: intermediateCompletion, finalCompletion: finalCompletion)
            }
            
            }, errorBlock: {
                (error) -> Void in
                
                print(error)
        })
    }
    
    class func broadcastTrack(track: EPTrack) {
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
    
    class func addTrackToPlaylistIfNeeded(track: EPTrack, completion: ((result:Bool, track:EPTrack?) -> Void)?) {
        print("adding track to playlist")
        
        if !EPSettings.shouldAutomaticallySaveToPlaylist() {
            //  If not required, call completion handled immediately (exit)
            if completion != nil {
                completion!(result: false, track: track)
            }
        } else {
            //  If required, add track to playlist first, then call the callback to initiate a track download
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
    }
    
    class func getPlaylistOfUserWithID(userID: Int?, count: Int?, completion: ((result:Bool, playlist:EPMusicPlaylist?) -> Void)?) {
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
