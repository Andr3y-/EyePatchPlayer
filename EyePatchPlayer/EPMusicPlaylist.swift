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
}
