//
//  EPMusicPlayer.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 17/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import AVFoundation

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
                self.audioStream = nil
                
                setupStream()
                
                self.audioStream!.playFromURL(activeTrack.URL)
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
        self.audioStream = FSAudioStream()
        self.audioStream?.configuration.maxDiskCacheSize = Int32(EPCache.maxDiskCacheSize())
        self.audioStream?.configuration.cacheDirectory = EPCache.cacheDirectory()
        self.audioStream?.configuration.cacheEnabled = EPCache.cacheEnabled()
        
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
    }
    
    //forward
    func forward() {
        
    }
    
    //backward
    
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
    
//    func setupSession() {
//        
//        //to enable playing in background
//        
//        let audioSession = AVAudioSession.sharedInstance()
//        var setCategoryError:NSError?
//        
//        var success = audioSession.setCategory(AVAudioSessionCategoryPlayback, error: &setCategoryError)
//        
//        if (!success) {
//            println("error")
//            //handle error
//        }
//        
//        var activationError:NSError?
//        
//        success = audioSession.setActive(true, error: &activationError)
//        
//        if (!success) {
//            println("error")
//        }
//
//    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        println("song finished playing")
    }
    

}
