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
    func playbackProgressUpdate(currentTime:Int, downloadedTime:Int)
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
    let updateProgressFrequency = 1.0
    var updateProgressTimer: NSTimer?
    //player
    var audioStream: FSAudioStream?
    //remote manager
    var remoteManager: EPMusicPlayerRemoteManager!
    //should cache currently played song
    var shouldCacheCurrentSong:Bool = false
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
    
    func requestCacheCurrentSong() {
        if (self.shouldCacheCurrentSong){
            println("already requested to cache this song")
        } else {
            self.shouldCacheCurrentSong = true
        }
    }
    
    func setTrack(track:EPTrack) {
        
        if let cachedTrackInstance = EPCache.trackCachedInstanceForTrack(track) {
            println("cache found")
            activeTrack = cachedTrackInstance as EPTrack
        } else {
            println("no cache found")
            activeTrack = track
        }
        
        if (shouldCacheCurrentSong){
            println("track changed, but has not been cached when requested, perhaps need to add separate download queue for that")
            shouldCacheCurrentSong = false
        }
        
        self.setupStream()
        
        if (activeTrack.isCached) {
            if (activeTrack.hasFileAtPath()) {
                println("attempting to play from cache:\n\(activeTrack.URL())")
                self.audioStream!.playFromURL(activeTrack.URL())
            } else {
                println("file is missing at path, cannot play")
            }
            
        } else {
            println("attempting to play from web")
            self.audioStream!.playFromURL(activeTrack.URL())
        }
        
        if EPSettings.shouldBroadcastStatus() {
            self.VKBroadcastTrack()
        }
        
        if EPSettings.shoulScrobbleWithLastFm() {
            //scrobble with LastFm
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
            if self.playlist.tracks[i] === activeTrack {
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
        
        var index: Int?
        
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
            if self.playlist.tracks[i] === activeTrack {
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
        let timeInSeconds = self.audioStream!.currentTimePlayed.playbackTimeInSeconds
        println("timeInSeconds: \(timeInSeconds)")
        self.delegate?.playbackProgressUpdate(Int(roundf(timeInSeconds)), downloadedTime: Int(availableDuration()))
        
        println("contentLength:        \(self.audioStream?.contentLength)")
        println("defaultContentLength: \(self.audioStream?.defaultContentLength)")
        println("prebufferedByteCount: \(self.audioStream?.prebufferedByteCount)")
        println("cached:               \(self.audioStream?.cached)")
        
        if self.audioStream?.cached == true {
            if (self.shouldCacheCurrentSong){
                
                self.audioStream?.outputFile = NSURL(fileURLWithPath: EPCache.pathForTrackToSave(activeTrack))
                if EPCache.addTrackToDownloadWithFileAtPath(activeTrack, filePath: EPCache.pathForTrackToSave(activeTrack)) {
                    self.delegate?.trackCachedWithResult(true)
                } else {
                    println("")
                    self.delegate?.trackCachedWithResult(false)
                }
                
                self.shouldCacheCurrentSong = false
            }
            
        }
    }
    
    func availableDuration() -> NSTimeInterval {
        return 0
    }
    
    func configureNowPlayingInfo() {
        var info = MPNowPlayingInfoCenter.defaultCenter()
        var newInfo = NSMutableDictionary()
        
        let itemProperties:NSSet = NSSet(objects: MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyPlaybackDuration, MPNowPlayingInfoPropertyElapsedPlaybackTime)
        
        newInfo[MPMediaItemPropertyTitle] = activeTrack.title
        newInfo[MPMediaItemPropertyArtist] = activeTrack.artist
        newInfo[MPMediaItemPropertyPlaybackDuration] = activeTrack.duration
        newInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.audioStream!.currentTimePlayed.playbackTimeInSeconds
        
        info.nowPlayingInfo = newInfo as [NSObject : AnyObject]
        
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        println("song finished playing")
    }
    

}
