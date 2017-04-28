//
//  EPHTTPVKManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 11/02/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import VK_ios_sdk
import Alamofire

class EPHTTPVKManager: NSObject {
    
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
                            
                            print(error ?? "unknown error")
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
}
