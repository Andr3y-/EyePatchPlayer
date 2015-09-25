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

enum PlaybackStatus {
    case Play
    case Pause
    case Unknown
}

protocol EPMusicPlayerDelegate {
    func playbackProgressUpdate(currentTime:Int, bufferedPercent:Double)
    func playbackStatusUpdate(playbackStatus:PlaybackStatus)
    func playbackTrackUpdate()
    func trackCachedWithResult(result: Bool)
}

class EPMusicPlayer: NSObject {
    
    //delegate
    var delegate: EPMusicPlayerDelegate?
    
    //singleton
    static let sharedInstance = EPMusicPlayer()
    var shuffleOn: Bool = true
    //progress update frequency
    let updateProgressFrequency = 0.1
    var updateProgressTimer: NSTimer?
    //player
    var audioStream: FSAudioStream?
    var audioStreamLocal: FSAudioStream?
//    var localPlayer: AVAudioPlayer?
    //remote manager
    var remoteManager: EPMusicPlayerRemoteManager!

    
    //playlist & current song
    var playlist: EPMusicPlaylist = EPMusicPlaylist()
    
    private(set) internal var activeTrack: EPTrack = EPTrack() {
        didSet {
           println("activeTrack didSet: \(activeTrack.artist) - \(activeTrack.title)\n\(activeTrack.URL())")
        }
    }
    
    override init() {
        
        super.init()
        
        self.remoteManager = EPMusicPlayerRemoteManager()
        self.setupStream()
    }
    
    func setTrack(track:EPTrack) {
        
        if let cachedTrackInstance = EPCache.trackCachedInstanceForTrack(track) {
            println("cache found")
            activeTrack = cachedTrackInstance as EPTrack
        } else {
            println("no cache found")
            activeTrack = track
        }
        
        self.setupStream()
        
        if (activeTrack.isCached) {
            if (activeTrack.hasFileAtPath()) {
//                println("HAS FILE AT PATH, attempting to play from cache:\n\(activeTrack.URL())")
                self.audioStream!.playFromURL(activeTrack.URL())
            } else {
//                println("FILE IS MISSING at path, cannot play")
            }
            
        } else {
//            println("attempting to play from web")
            self.audioStream!.playFromURL(activeTrack.URL())
        }
        
        if EPSettings.shouldBroadcastStatus() { self.VKBroadcastTrack() }
        if EPSettings.shoulScrobbleWithLastFm() { /*scrobble with LastFm */ }
        if EPSettings.shouldDownloadArtwork() {
        
        }
        //should be performed by a separate class
        self.configureNowPlayingInfo()
        
        resetTimer()
        
        self.delegate?.playbackTrackUpdate()
    }
    
    func resetTimer() {
        if ((self.updateProgressTimer) != nil) {
            self.updateProgressTimer?.invalidate()
        }
        
        updateProgressTimer = NSTimer.scheduledTimerWithTimeInterval(updateProgressFrequency, target: self, selector: "updateProgress", userInfo: nil, repeats: true)

    }
    
    func setupStream() {
        println("stream setup for a first time")
        self.audioStream = nil
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
        let broadcastRequest: VKRequest = VKRequest(method: "audio.setBroadcast", andParameters: ["audio" : "\(activeTrack.ownerID)_\(activeTrack.ID)"], andHttpMethod: "GET")
        broadcastRequest.executeWithResultBlock({ (response) -> Void in
            println("broadcasting track success result: \(response)")
        }, errorBlock: { (error) -> Void in
            println(error)
        })
    }
    
    func playTrackFromPlaylist(track: EPTrack, playlist: EPMusicPlaylist) {
        if (track.ID != activeTrack.ID){
            setTrack(track)
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
            if self.playlist.tracks[i].ID == activeTrack.ID {
                index = i
                break
            }
        }
        
        if let indexFound = index {
            if indexFound == self.playlist.tracks.count-1 {
                //last item, cannot forward
                
            } else {
                setTrack(self.playlist.tracks[indexFound+1])
            }
        } else {
            println("index not found in a playlist")
        }
    }
    
    func forwardRandom() {
        println("forward random")
                
        if (self.playlist.tracks.count > 0){
            setTrack(self.playlist.tracks[Int(arc4random_uniform(UInt32(self.playlist.tracks.count)))])
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
            if self.playlist.tracks[i].ID == activeTrack.ID {
                index = i
                break
            }
        }
        
        if let indexFound = index {
            if indexFound == 0 {
                //first item, cannot backward
                
            } else {
                setTrack(self.playlist.tracks[indexFound-1])
            }
        } else {
            println("index not found in a playlist")
        }
    }
    
    //updating playback progress as well as download progress
    func updateProgress() {
        if self.audioStream!.isPlaying() {
            let timeInSeconds = self.audioStream!.currentTimePlayed.playbackTimeInSeconds
//            println("timeInSeconds: \(timeInSeconds)")
            
            var prebufferedPercent: Double = 0.0
            if self.audioStream?.cached == false {
                if let contentSize = self.audioStream?.contentLength, contentDownloaded = self.audioStream?.prebufferedByteCount {
                    prebufferedPercent = Double(contentDownloaded) / Double(contentSize)
                }
            } else {
                prebufferedPercent = 1.0
            }
            self.delegate?.playbackProgressUpdate(Int(roundf(timeInSeconds)), bufferedPercent: prebufferedPercent)
            
//            println("contentLength:        \(self.audioStream?.contentLength)")
//            println("defaultContentLength: \(self.audioStream?.defaultContentLength)")
//            println("prebufferedByteCount: \(self.audioStream?.prebufferedByteCount)")
//            println("cached:               \(self.audioStream?.cached)")
            
        }
        
    }
    
    func availableDuration() -> NSTimeInterval {
        return 0
    }
    
    func configureNowPlayingInfo() {
        var info = MPNowPlayingInfoCenter.defaultCenter()
        var newInfo = NSMutableDictionary()
//        let itemProperties:NSSet = NSSet(objects: MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyPlaybackDuration, MPNowPlayingInfoPropertyElapsedPlaybackTime)
        
        newInfo[MPMediaItemPropertyTitle] = activeTrack.title
        newInfo[MPMediaItemPropertyArtist] = activeTrack.artist
        newInfo[MPMediaItemPropertyPlaybackDuration] = activeTrack.duration
        newInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.audioStream!.currentTimePlayed.playbackTimeInSeconds
//        newInfo[MPMediaItemPropertyArtwork]
        
        info.nowPlayingInfo = newInfo as [NSObject : AnyObject]
        
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        println("song finished playing")
    }
    

}
