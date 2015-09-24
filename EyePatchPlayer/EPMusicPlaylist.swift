//
//  EPMusicPlaylist.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPMusicPlaylist: NSArray {
    var tracks: [EPTrack] = []
    var trackCount: Int = 0
    
    class func initWithResponse(response: NSDictionary) -> EPMusicPlaylist{
        var playlist: EPMusicPlaylist = EPMusicPlaylist()
        
        playlist.trackCount = response["count"]!.integerValue
        
        
//        println(response["items"])
        
        if let JSONArray: NSArray = response["items"] as? NSArray {
            for trackJSON in JSONArray {
//                println(trackJSON)
                let track:EPTrack = EPTrack.initWithResponse(trackJSON as! NSDictionary)
                playlist.tracks.append(track)
            }
        } else {
            println("response[\"items\" is empty]")
        }

        
        println("track count total: \(playlist.trackCount)")
        println("track count loaded: \(playlist.tracks.count)")
        
        return playlist
    }
    
    func removeTrack(track: EPTrack) -> Bool {
        var result = false
        
        for index in 0...self.tracks.count-1 {
            if self.tracks[index].ID == track.ID {
                self.tracks.removeAtIndex(index)
                return true
            }
        }
        
        return result
    }
    
    class func initWithRLMResults(results:RLMResults) -> EPMusicPlaylist {
        var playlist: EPMusicPlaylist = EPMusicPlaylist()

        if (results.count > 0 ) {
            for trackRLM in results {
                if let track: EPTrack = trackRLM as? EPTrack {
                    playlist.tracks.append(track)
                }
            }
        } else {
            println("results[\"items\" is empty]")
        }
        
        
        println("track count total: \(playlist.trackCount)")
        println("track count loaded: \(playlist.tracks.count)")
    
        return playlist
    }
}
