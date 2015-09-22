//
//  EPMusicPlayer.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 17/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

extension Array {
    func find(includedElement: T -> Bool) -> Int? {
        for (idx, element) in enumerate(self) {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
}


enum PlaybackStatus {
    case Play
    case Pause
    case Unknown
}

protocol EPMusicPlayerDelegate {
    func playbackProgressUpdate(currentTime:Int, downloadedTime:Int)
    func playbackStatusUpdate(playbackStatus:PlaybackStatus)
    func playbackTrackUpdate()
}

class EPMusicPlayer: NSObject {
    
    //delegate
    var delegate: EPMusicPlayerDelegate?
    
    //singleton
    static let sharedInstance = EPMusicPlayer()
    var shuffleOn: Bool = true
    //progress update frequency
    let updateProgressFrequency = 1.0
    var updateProgressTimer: NSTimer?
    //player
    var audioStream: FSAudioStream?

    //playlist & current song
    var playlist: EPMusicPlaylist = EPMusicPlaylist()
    var activeTrack: EPTrack = EPTrack() {
        didSet {
            //check if song is cached
            if (activeTrack.isCached){
                
            } else {
//                self.audioStream = nil
                if (self.audioStream == nil) {
                    setupStream()
                }
                
                
                self.audioStream!.playFromURL(activeTrack.URL)
                self.VKBroadcastTrack()
                self.configureNowPlayingInfo()
                self.delegate?.playbackTrackUpdate()
                
                if ((self.updateProgressTimer) != nil) {
                    self.updateProgressTimer?.invalidate()
                }
                
                updateProgressTimer = NSTimer.scheduledTimerWithTimeInterval(updateProgressFrequency, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
                
            }
        }
        
        willSet {
            println("setting new active song on a player")
            
            if (activeTrack.ID != 0 && activeTrack.ID != newValue.ID) {
                
                println("willSet: removing observers, cleaning")
                
                self.delegate?.playbackStatusUpdate(PlaybackStatus.Pause)
                
            } else {
                println("willSet: called for a first time or same song, no need to clean")
            }
        }
    }
    
    func setupStream() {
        println("stream setup for a first time")
        self.audioStream = FSAudioStream()
        self.audioStream?.configuration.maxDiskCacheSize = Int32(EPCache.maxDiskCacheSize())
        self.audioStream?.configuration.cacheDirectory = EPCache.cacheDirectory()
        self.audioStream?.configuration.cacheEnabled = EPCache.cacheEnabled()
        self.audioStream?.onCompletion = {
            self.playNextSong()
        }
        self.audioStream?.onStateChange = { state in
            switch state {
            case .FsAudioStreamPlaying:
                self.configureNowPlayingInfo()
                break
            case .FsAudioStreamPaused:
                self.configureNowPlayingInfo()
                break
            default:
                
                break
            }
        }
    }
    
    func VKBroadcastTrack() {
        println("broadcasting track")
        let broadcastRequest: VKRequest = VKRequest(method: "audio.setBroadcast", andParameters: ["audio" : "\(self.activeTrack.ownerID)_\(self.activeTrack.ID)"], andHttpMethod: "GET")
        broadcastRequest.executeWithResultBlock({ (response) -> Void in
            println("broadcasting track success result: \(response)")
        }, errorBlock: { (error) -> Void in
            println(error)
        })
//        [VKRequest requestWithMethod:@"wall.get" andParameters:@{VK_API_OWNER_ID : @"-1"} andHttpMethod:@"GET"];

    }
    
    func playTrackFromPlaylist(track: EPTrack, playlist: EPMusicPlaylist) {
        if (track.ID != self.activeTrack.ID){
            self.activeTrack = track
        }
        
        self.playlist = playlist
    }
    
    
    
    //togglePlayPause
    func togglePlayPause() {
        println("togglePlayPause")
        if (self.audioStream!.isPlaying()) {
            println("pausing")
            self.audioStream!.pause()
            self.delegate?.playbackStatusUpdate(PlaybackStatus.Pause)
        } else {
            println("playing")
            self.audioStream!.pause()
            self.delegate?.playbackStatusUpdate(PlaybackStatus.Play)
        }
        self.configureNowPlayingInfo()
    }
    
    //forward
    func playNextSong() {
        if (self.shuffleOn){
            self.forwardRandom()
        } else {
            self.forward()
        }
    }
    
    func forward() {
        println("forward called")
        var index: Int?
        for i in (0...self.playlist.tracks.count-1) {
            if self.playlist.tracks[i] === self.activeTrack {
                index = i
                break
            }
        }
        
        if let indexFound = index {
            if indexFound == self.playlist.tracks.count-1 {
                //last item, cannot forward
                
            } else {
                self.activeTrack = self.playlist.tracks[indexFound+1]
            }
        } else {
            println("index not found in a playlist")
        }
    }
    
    func forwardRandom() {
        println("forward random")
        
        var index: Int?
        
        if (self.playlist.tracks.count > 0){
            self.activeTrack = self.playlist.tracks[Int(arc4random_uniform(UInt32(self.playlist.tracks.count)))]
        }
    }
    
    //backward
    func playPrevSong() {
        if (self.shuffleOn){
            self.forwardRandom()
        } else {
            self.backward()
        }
    }
    
    func backward() {
        println("backward called")
        var index: Int?
        for i in (0...self.playlist.tracks.count-1) {
            if self.playlist.tracks[i] === self.activeTrack {
                index = i
                break
            }
        }
        
        if let indexFound = index {
            if indexFound == 0 {
                //first item, cannot backward
                
            } else {
                self.activeTrack = self.playlist.tracks[indexFound-1]
            }
        } else {
            println("index not found in a playlist")
        }
    }
    
    //updating playback progress as well as download progress
    func updateProgress() {
        let timeInSeconds = self.audioStream!.currentTimePlayed.playbackTimeInSeconds
        println("timeInSeconds: \(timeInSeconds)")
        self.delegate?.playbackProgressUpdate(Int(roundf(timeInSeconds)), downloadedTime: Int(availableDuration()))
        
        println("contentLength:        \(self.audioStream?.contentLength)")
        println("defaultContentLength: \(self.audioStream?.defaultContentLength)")
        println("prebufferedByteCount: \(self.audioStream?.prebufferedByteCount)")
        println("cached:               \(self.audioStream?.cached)")
        
        if self.audioStream?.cached == true {
            self.audioStream?.outputFile = NSURL(fileURLWithPath: EPCache.pathForTrackToSave(self.activeTrack))
        }
    }
    
    func availableDuration() -> NSTimeInterval {
        return 0
    }
    
    func configureNowPlayingInfo() {
        var info = MPNowPlayingInfoCenter.defaultCenter()
        var newInfo = NSMutableDictionary()
        
        let itemProperties:NSSet = NSSet(objects: MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyPlaybackDuration, MPNowPlayingInfoPropertyElapsedPlaybackTime)
        
        newInfo[MPMediaItemPropertyTitle] = self.activeTrack.title
        newInfo[MPMediaItemPropertyArtist] = self.activeTrack.artist
        newInfo[MPMediaItemPropertyPlaybackDuration] = self.activeTrack.duration
        newInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.audioStream!.currentTimePlayed.playbackTimeInSeconds
        
        info.nowPlayingInfo = newInfo as [NSObject : AnyObject]
        
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        println("song finished playing")
    }
    

}
