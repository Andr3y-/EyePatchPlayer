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
    var delegate:EPPlaylistDelegate?
    
    private lazy var shuffledTracks: [EPTrack] = {
        print("lazily loading shuffled playlist")
        var shuffledTracksLazy = self.tracks.shuffle()
        return shuffledTracksLazy
    }()
    var trackCount: Int = 0
    var shuffleOn: Bool = true
    
    func nextTrack() -> EPTrack? {
        let startTime = CFAbsoluteTimeGetCurrent()

        print("nextTrack")
        var index: Int?
        var tracksArray: [EPTrack]
        
        if shuffleOn {
            tracksArray = self.shuffledTracks
        } else {
            tracksArray = self.tracks
        }
        
        for i in (0...tracksArray.count-1) {
            if tracksArray[i].ID == EPMusicPlayer.sharedInstance.activeTrack.ID {
                index = i
                break
            }
        }
        
        if let indexFound = index {
            if indexFound == tracksArray.count-1 {
                if shuffleOn {
                    //last item, shuffle is on, playing first item from shuffled array
                    return tracksArray[0]
                } else {
                    //last item, cannot forward
                    print("index is max in a playlist, cannot get next track")
                    return nil
                }
                
            } else {
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                print("\(previousTrack):: Time: \(timeElapsed)")
                return tracksArray[indexFound+1]
            }
        } else {
            print("index not found in a playlist")
        }
        
        return nil
    }
    
    func previousTrack() -> EPTrack? {
        let startTime = CFAbsoluteTimeGetCurrent()

        print("previousTrack")
        var index: Int?
        var tracksArray: [EPTrack]
        
        if shuffleOn {
            tracksArray = self.shuffledTracks
        } else {
            tracksArray = self.tracks
        }
        
        for i in (0...tracksArray.count-1) {
            if tracksArray[i].ID == EPMusicPlayer.sharedInstance.activeTrack.ID {
                index = i
                break
            }
        }
        
        if let indexFound = index {
            if indexFound == 0 {
                
                if shuffleOn {
                    //last item, shuffle is on, playing last item from shuffled array
                    return tracksArray[tracksArray.count-1]
                } else {
                    //last item, cannot backward
                    print("index is 0 in a playlist, cannot get previous track")
                    return nil
                }
                
            } else {
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                print("\(previousTrack):: Time: \(timeElapsed)")
                return tracksArray[indexFound-1]
            }
        } else {
            print("index not found in a playlist")
        }
        
        return nil
    }
    
    func removeTrack(track: EPTrack) -> Bool {
        var resultLinear = false
        var resultShuffled = false
        
        for index in 0...self.tracks.count-1 {
            
            if self.tracks[index].ID == track.ID {
                self.tracks.removeAtIndex(index)
                resultLinear = true
            }
            
            if self.shuffledTracks[index].ID == track.ID {
                self.shuffledTracks.removeAtIndex(index)
                resultShuffled = true
            }
            
        }
        
        return resultLinear && resultShuffled
    }
    
    
//MARK: Init methods
    
    class func initWithResponse(response: NSDictionary) -> EPMusicPlaylist{
        let playlist: EPMusicPlaylist = EPMusicPlaylist()
        
        playlist.trackCount = response["count"]!.integerValue
        
//        EPCache.cacheRetrievalExecutionTime = 0
        if let JSONArray: NSArray = response["items"] as? NSArray {
            for trackJSON in JSONArray {
                
                let track:EPTrack = EPTrack.initWithResponse(trackJSON as! NSDictionary)
                playlist.tracks.append(track)
            }
        } else {
            print("response[\"items\" is empty]")
        }
        
        playlist.shuffledTracks = playlist.tracks.shuffle()
        
        print("track count total: \(playlist.trackCount)")
        print("track count loaded: \(playlist.tracks.count)")
        
        return playlist
    }

    class func initWithRLMResults(results:RLMResults) -> EPMusicPlaylist {
        let playlist: EPMusicPlaylist = EPMusicPlaylist()

        if (results.count > 0 ) {
            for trackRLM in results {
                if let track: EPTrack = trackRLM as? EPTrack {
                    playlist.tracks.append(track)
                }
            }
        } else {
            print("results[\"items\" is empty]")
        }
        
        
        print("track count total: \(playlist.trackCount)")
        print("track count loaded: \(playlist.tracks.count)")
    
        return playlist
    }
}
