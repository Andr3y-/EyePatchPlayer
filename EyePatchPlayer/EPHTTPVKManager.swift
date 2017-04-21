//
//  EPHTTPVKManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 11/02/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import VK_ios_sdk
import AFNetworking
import Mantle

class EPHTTPVKManager: NSObject {
    
    class func getLastAudiosFromMessages(_ count: Int, intermediateResultBlock: ((_ track:EPTrack) -> Void)?, completion: ((_ result:Bool, _ tracks:[EPTrack]?) -> Void)?) {
        if let _ = VKSdk.getAccessToken().userId {
            print("VKGetLastAudiosFromMessages request")
            
            let messagesPerRequestCount = 200
            let currentOffset = 0
            
            EPHTTPVKManager.getAudiosFromMessagesWithCountOffset(count, messagesPerRequestCount: messagesPerRequestCount, offset: currentOffset, tracksArray: [EPTrack](), intermediateCompletion: intermediateResultBlock, finalCompletion: {
                (tracks) -> Void in
                print("tracks parsed: \(tracks.count)")
                if completion != nil {
                    completion!(count >= tracks.count, tracks)
                }
            })
            
        } else {
            print("VKGetLastAudiosFromMessages: could not resolve VK UserID")
            
            if completion != nil {
                completion!(false, nil)
            }
        }
    }
    
    private class func getAudiosFromMessagesWithCountOffset(_ requiredCount: Int, messagesPerRequestCount: Int, offset: Int, tracksArray: [EPTrack], intermediateCompletion: ((_ track:EPTrack) -> Void)?, finalCompletion: ((_ tracks:[EPTrack]) -> Void)?) {
        var tracksArray = tracksArray
        print("VKGETAudiosFromMessagesWithCount: \(requiredCount) Offset: \(offset) CurrentTracksCount: \(tracksArray.count)")
        
        let addRequest: VKRequest = VKRequest(method: "messages.get", andParameters: ["count": "\(messagesPerRequestCount)", "offset": "\(offset)"], andHttpMethod: "GET")
        addRequest.execute(resultBlock: {
            (response) -> Void in
            if let messagesArray = (response?.json as! NSDictionary)["items"] as? [NSDictionary] {
                for messageJSON in messagesArray {
                    let message = EPMessage(response: messageJSON)
                    if let messageAttachments = message.attachments {
                        for attachment in messageAttachments {
                            if attachment.type == AttachmentType.Audio {
                                if let track = attachment.object as? EPTrack {
                                    
                                    tracksArray.append(track)
                                    print("track parsed")
                                    if intermediateCompletion != nil {
                                        intermediateCompletion!(track)
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
                    finalCompletion!(tracksArray)
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
    
    class func broadcastTrack(_ track: EPTrack) {
        //        print("broadcasting track")
        if !AFNetworkReachabilityManager.shared().isReachable {
            return
        }
        let broadcastRequest: VKRequest = VKRequest(method: "audio.setBroadcast", andParameters: ["audio": "\(track.uniqueID)"], andHttpMethod: "GET")
        broadcastRequest.execute(resultBlock: {
            (response) -> Void in
            print("broadcasting track success result: \(response?.json)")
            }, errorBlock: {
                (error) -> Void in
                print(error)
        })
    }
    
    class func addTrackToPlaylistIfNeeded(_ track: EPTrack, completion: ((_ result:Bool, _ track:EPTrack?) -> Void)?) {
        print("adding track to playlist")
        
        if !EPSettings.shouldAutomaticallySaveToPlaylist() {
            //  If not required, call completion handled immediately (exit)
            if completion != nil {
                completion!(false, track)
            }
        } else {
            //  If required, add track to playlist first, then call the callback to initiate a track download
            if let userID = VKSdk.getAccessToken().userId {
                
                if userID == "\(track.ownerID)" {
                    //track already in the playlist
                    print("adding track to playlist success result: track is already in the playlist")
                    if completion != nil {
                        completion!(true, track)
                    }
                } else {
                    //track is not in the playlist, adding it
                    let addRequest: VKRequest = VKRequest(method: "audio.add", andParameters: ["audio_id": "\(track.ID)", "owner_id": track.ownerID], andHttpMethod: "GET")
                    addRequest.execute(resultBlock: {
                        (response) -> Void in
                        
                        var result: Bool = false
                        
                        defer {
                            if let completion = completion {
                                completion(result, track)
                            }
                        }
                        
                        guard let
                            newID = response?.json as? Int,
                            let newOwnerID = Int(VKSdk.getAccessToken().userId) else {
                                return
                        }
                        
                        print("adding track to playlist success result: \(newID)")
                        //update track ID
                        
                        track.ID = newID
                        track.ownerID = newOwnerID
                        
                        result = true
                        
                        }, errorBlock: {
                            (error) -> Void in
                            if completion != nil {
                                completion!(false, nil)
                            }
                            
                            print(error)
                    })
                }
                
            } else {
                print("adding track to playlist success result: could not resolve VK UserID")
                
                if completion != nil {
                    completion!(false, nil)
                }
            }
        }
    }
    
    class func getPlaylistOfUserWithID(_ userID: Int?, count: Int?, completion: ((_ result:Bool, _ playlist:EPMusicPlaylist?) -> Void)?) {
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
        
        audioRequest.execute(resultBlock: {
            (response) -> Void in
            
            let playlist = EPMusicPlaylist.initWithResponse(response?.json as! NSDictionary)
            
            if completion != nil {
                completion!(true, playlist)
            }
            
            }, errorBlock: {
                (error) -> Void in
                if completion != nil {
                    completion!(false, nil)
                }
        })
    }
    
    class func getLyricsForTrack(_ track: EPTrack, completion: ((_ result:Bool, _ lyrics:EPLyrics?, _ trackUniqueID:String) -> Void)?) {
        
        print("checking lyrics for track")
        let trackUniqueID = track.uniqueID
        let trackDetailsRequest: VKRequest = VKRequest(method: "audio.getById", andParameters: ["audios": "\(track.uniqueID)"], andHttpMethod: "GET")
        trackDetailsRequest.execute(resultBlock: {
            (response) -> Void in

            if let responseArray = response?.json as? [NSDictionary] {
                if responseArray.count < 1 {
                    if completion != nil {
                        completion!(false, nil, trackUniqueID)
                    }
                    return
                }
                let downloadedTrack = EPTrack.initWithResponse(responseArray.first!)
                if let lyricsID = downloadedTrack.lyricsID {
                    let lyricsRequest: VKRequest = VKRequest(method: "audio.getLyrics", andParameters: ["lyrics_id": "\(lyricsID)"], andHttpMethod: "GET")
                    lyricsRequest.execute(resultBlock: {
                        (response) -> Void in
                        if let responseDictionary = response?.json as? NSDictionary {
                            let lyrics = EPLyrics(dictionary: responseDictionary)
                            if completion != nil {
                                completion!(true, lyrics, trackUniqueID)
                            }
                            return
                        }
                        return
                        }, errorBlock: {
                            (error) -> Void in
                            
                    })
                } else {
                    if completion != nil {
                        completion!(false, nil, trackUniqueID)
                    }
                    return
                }
            } else {
                if completion != nil {
                    completion!(false, nil, trackUniqueID)
                }
                return
            }
            
            }, errorBlock: {
                (error) -> Void in
                if completion != nil {
                    completion!(false, nil, trackUniqueID)
                }
                return
        })
    }
    
    class func getAlbumsOfUserWithID(_ userID: Int, count: Int?, completion: ((_ result:Bool, _ albums:[EPAlbum]?) -> Void)?) {
        
        let audioRequest: VKRequest = VKRequest(method: "audio.getAlbums", andParameters: [VK_API_OWNER_ID: userID, VK_API_COUNT: count != nil ? count! : 100], andHttpMethod: "GET")
        
        audioRequest.execute(resultBlock: {
            (response) -> Void in
            
            var albums = [EPAlbum]()
            
            if let albumsArray = (response?.json as! NSDictionary)["items"] as? [[AnyHashable: Any]] {
                for albumDictionary in albumsArray {
                    
                    do {
                        if let album = try MTLJSONAdapter.model(of: EPAlbum.self, fromJSONDictionary: albumDictionary) as? EPAlbum {
                            albums.append(album)
                        }
                    } catch let error {
                        print(error)
                    }
                    
                }
            } else {
                print("albumsArray none")
            }
            
            if completion != nil {
                completion!(true, albums)
            }
            
            }, errorBlock: {
                (error) -> Void in
                if completion != nil {
                    completion!(false, nil)
                }
        })
    }
}
