//
//  EPMusicPlaylist.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPMusicPlaylist: AnyObject {

    var tracks: [EPTrack] {
        get {
            return shuffleOn ? shuffledTracks : originalTracks
        }
    }
    
    var delegate:EPPlaylistDelegate?
    
    private var originalTracks:[EPTrack] = []
    
    lazy var shuffledTracks: [EPTrack] = {
        print("lazily loading shuffled playlist")
        var shuffledTracksLazy = self.originalTracks.shuffle()
        return shuffledTracksLazy
    }()
    
    var trackCount: Int = 0
    var shuffleOn: Bool = false {
        didSet {
            print("playlistShuffle changed")
            self.delegate?.playlistDidChangeOrder()
        }
    }
    var responseJSON: NSDictionary?
    
    //MARK: Playlist control interface
    
    func nextTrack() -> EPTrack? {
        let startTime = CFAbsoluteTimeGetCurrent()

        print("nextTrack")
        var index: Int?
        
        for i in (0...tracks.count-1) {
            if tracks[i].ID == EPMusicPlayer.sharedInstance.activeTrack.ID {
                index = i
                break
            }
        }
        
        if let indexFound = index {
            if indexFound == tracks.count-1 {
                if shuffleOn {
                    //last item, shuffle is on, playing first item from shuffled array
                    return tracks[0]
                } else {
                    //last item, cannot forward
                    print("index is max in a playlist, cannot get next track")
                    return nil
                }
                
            } else {
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                print("\(previousTrack):: Time: \(timeElapsed)")
                return tracks[indexFound+1]
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
        
        for i in (0...tracks.count-1) {
            if tracks[i].ID == EPMusicPlayer.sharedInstance.activeTrack.ID {
                index = i
                break
            }
        }
        
        if let indexFound = index {
            if indexFound == 0 {
                
                if shuffleOn {
                    //last item, shuffle is on, playing last item from shuffled array
                    return tracks[tracks.count-1]
                } else {
                    //last item, cannot backward
                    print("index is 0 in a playlist, cannot get previous track")
                    return nil
                }
                
            } else {
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                print("\(previousTrack):: Time: \(timeElapsed)")
                return tracks[indexFound-1]
            }
        } else {
            print("index not found in a playlist")
        }
        
        return nil
    }
    
    func reshuffle() {
        self.shuffledTracks = self.originalTracks.shuffle()
        self.shuffleOn = true
    }
    
    //MARK: Playlist Editing
    
    func removeTrack(track: EPTrack) -> Bool {
        
        var resultLinear = false
        var resultShuffled = false
        
        for index in 0...self.originalTracks.count-1 {
            if self.originalTracks[index].ID == track.ID {
                self.originalTracks.removeAtIndex(index)
                resultLinear = true
                break
            }
        }
        
        for index in 0...self.shuffledTracks.count-1 {
            if self.shuffledTracks[index].ID == track.ID {
                self.shuffledTracks.removeAtIndex(index)
                resultShuffled = true
                break
            }
        }
        
        return resultLinear && resultShuffled
    }
    
    func addTrack(track: EPTrack) {
        self.originalTracks.append(track)
        self.shuffledTracks = self.originalTracks.shuffle()
        self.trackCount = self.originalTracks.count
    }
    
    //MARK: Init methods
    init () {
        
    }
    
    init(tracks: [EPTrack]) {
        self.originalTracks = tracks
        self.trackCount = self.originalTracks.count
    }
    
    class func initWithResponseArray(response: NSArray) -> EPMusicPlaylist {
        let playlist: EPMusicPlaylist = EPMusicPlaylist()
        
        for trackJSON in response {
            let track:EPTrack = EPTrack.initWithResponse(trackJSON as! NSDictionary)
            playlist.originalTracks.append(track)
        }
        
        playlist.shuffledTracks = playlist.originalTracks.shuffle()
        
        print("track count total: \(playlist.trackCount)")
        print("track count loaded: \(playlist.originalTracks.count)")
        
        return playlist

    }
    
    class func initWithResponse(response: NSDictionary) -> EPMusicPlaylist{
        let playlist: EPMusicPlaylist = EPMusicPlaylist()
        
        playlist.responseJSON = response
        playlist.trackCount = response["count"]!.integerValue
        
        //        EPCache.cacheRetrievalExecutionTime = 0
        if let JSONArray: NSArray = response["items"] as? NSArray {
            for trackJSON in JSONArray {
                
                let track:EPTrack = EPTrack.initWithResponse(trackJSON as! NSDictionary)
                playlist.originalTracks.append(track)
            }
        } else {
            print("response[\"items\" is empty]")
        }
        
        playlist.shuffledTracks = playlist.originalTracks.shuffle()
        
        print("track count total: \(playlist.trackCount)")
        print("track count loaded: \(playlist.originalTracks.count)")
        
        return playlist
    }
    
    class func initWithRLMResults(results:RLMResults) -> EPMusicPlaylist {
        let playlist: EPMusicPlaylist = EPMusicPlaylist()

        if (results.count > 0 ) {
            for trackRLM in results {
                if let track: EPTrack = trackRLM as? EPTrack {
                    playlist.originalTracks.append(track)
                }
            }
        } else {
            print("results[\"items\" is empty]")
        }
        
        print("track count total: \(playlist.trackCount)")
        print("track count loaded: \(playlist.originalTracks.count)")
    
        return playlist
    }
}
