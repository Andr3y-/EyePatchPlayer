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
    
    //player
    var audioPlayer = AVPlayer()

    //playlist & current song
    var playlist: EPMusicPlaylist = EPMusicPlaylist()
    var activeSong: EPTrack = EPTrack() {
        didSet {
            //check if song is cached
            if (activeSong.isCached){
                
            } else {
                self.audioPlayer = AVPlayer(URL: activeSong.URL)
                
                setupSession()
                setupObservers()
                
                self.delegate?.playbackTrackUpdate()
            }
        }
        
        willSet {
            println("setting new active song on a player")
            
            if (activeSong.ID != 0 && activeSong.ID != newValue.ID) {
                
                println("willSet: removing observers, cleaning")
                removeObservers()
                self.audioPlayer.pause()
                self.delegate?.playbackStatusUpdate(PlaybackStatus.Pause)
                
            } else {
                println("willSet: called for a first time or same song, no need to clean")
            }
        }
    }
    
    func playTrackFromPlaylist(track: EPTrack, playlist: EPMusicPlaylist) {
        if (track.ID != self.activeSong.ID){
            self.activeSong = track
        }
        
        self.playlist = playlist
    }
    
    //KVO setup
    func setupObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.audioPlayer.currentItem)
        
        self.audioPlayer.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        //        self.audioPlayer.addObserver(self, forKeyPath: "loadedTimeRanges", options:NSKeyValueObservingOptions.Initial | NSKeyValueObservingOptions.New, context:nil)
        
        NSTimer.scheduledTimerWithTimeInterval(self.updateProgressFrequency, target: self, selector: "updateProgress:", userInfo: nil, repeats: true)
        println("observers setup complete")
    }
    
    //KVO removal
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.audioPlayer.removeObserver(self, forKeyPath: "status")
        println("observers removed")
    }
    
    //KVO serving
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (object as! NSObject == self.audioPlayer && keyPath == "status") {
            switch audioPlayer.status {
            case AVPlayerStatus.Failed:
                println("failed playback")
            case AVPlayerStatus.ReadyToPlay:
                println("ready to play")
                self.audioPlayer.play()
                self.delegate?.playbackStatusUpdate(PlaybackStatus.Play)
            default:
                println("AVPlayer Unknown Status")
            }
        }
    }
    
    //togglePlayPause
    func togglePlayPause() {
        println("togglePlayPause\nrate: \(self.audioPlayer.rate)")
        if (self.audioPlayer.rate > 0 && (self.audioPlayer.error == nil)) {
            //is playing
            println("pausing")
            self.audioPlayer.pause()
            self.delegate?.playbackStatusUpdate(PlaybackStatus.Pause)
        } else {
            //is not playing
            println("playing")
            self.audioPlayer.play()
            self.delegate?.playbackStatusUpdate(PlaybackStatus.Play)
        }
    }
    
    //forward
    func forward() {
        
    }
    
    //backward
    
    //updating playback progress as well as download progress
    func updateProgress(userInfo:NSObject) {
        let timeInSeconds = CMTimeGetSeconds(self.audioPlayer.currentTime())
        
        self.delegate?.playbackProgressUpdate(Int(Double((timeInSeconds))), downloadedTime: Int(availableDuration()))
    }
    
    func availableDuration() -> NSTimeInterval {
        let loadedTimeRanges = self.audioPlayer.currentItem.loadedTimeRanges
        let result: NSTimeInterval = 0
        
        if let timeRange = loadedTimeRanges.first?.CMTimeRangeValue {
            let startSeconds = CMTimeGetSeconds(timeRange.start)
            let durationSeconds = CMTimeGetSeconds(timeRange.duration)
            let result = startSeconds + durationSeconds
        }
        
        return result
    }
    
    func setupSession() {
        
        //to enable playing in background
        
        let audioSession = AVAudioSession.sharedInstance()
        var setCategoryError:NSError?
        
        var success = audioSession.setCategory(AVAudioSessionCategoryPlayback, error: &setCategoryError)
        
        if (!success) {
            println("error")
            //handle error
        }
        
        var activationError:NSError?
        
        success = audioSession.setActive(true, error: &activationError)
        
        if (!success) {
            println("error")
        }

    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        println("song finished playing")
    }
    

}
