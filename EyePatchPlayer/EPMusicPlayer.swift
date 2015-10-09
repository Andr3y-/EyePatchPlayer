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

class EPMusicPlayer: NSObject {
    
    //delegate
    var delegate: EPMusicPlayerDelegate?
    
    //singleton
    static let sharedInstance = EPMusicPlayer()
//    var shuffleOn: Bool = true
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
           print("activeTrack didSet: \(activeTrack.artist) - \(activeTrack.title)\n\(activeTrack.URL())")
        }
    }
    
    override init() {
        
        super.init()
        
        self.remoteManager = EPMusicPlayerRemoteManager()
        self.setupStream()
        self.observeRouteChanges()
    }
    
    func setTrack(track:EPTrack) {
        
        self.activeTrack.clearArtworkImage()
        
        if let cachedTrackInstance = EPCache.trackCachedInstanceForTrack(track) {
            print("cache found")
            activeTrack = cachedTrackInstance as EPTrack
        } else {
            print("no cache found")
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
            
            if let _ = activeTrack.artworkImage() {
                self.delegate?.trackRetrievedArtworkImage(self.activeTrack.artworkImage()!)
                self.remoteManager.configureNowPlayingInfo(activeTrack)
            } else {
                if EPSettings.shouldDownloadArtwork() {
                    EPHTTPManager.getAlbumCoverImage(activeTrack, completion: { (result, image, trackID) -> Void in
                        if result && trackID == self.activeTrack.ID {
                            self.delegate?.trackRetrievedArtworkImage(self.activeTrack.artworkImage()!)
                            self.remoteManager.configureNowPlayingInfo(self.activeTrack)
                        }
                    })
                }
            }
            
        } else {
//            println("attempting to play from web")
            if EPSettings.shouldDownloadArtwork() {
                EPHTTPManager.getAlbumCoverImage(activeTrack, completion: { (result, image, trackID) -> Void in
                    if result == true && trackID == self.activeTrack.ID {
                        self.delegate?.trackRetrievedArtworkImage(self.activeTrack.artworkImage()!)
                        self.remoteManager.configureNowPlayingInfo(self.activeTrack)
                    }
                })
            }
            self.audioStream!.playFromURL(activeTrack.URL())
        }
        
        if EPSettings.shouldBroadcastStatus() { EPHTTPManager.VKBroadcastTrack(self.activeTrack) }
        if EPSettings.shoulScrobbleWithLastFm() { EPHTTPManager.scrobbleTrack(self.activeTrack) }
        
        //should be performed by a separate class
        self.remoteManager.configureNowPlayingInfo(self.activeTrack)
        
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
        print("stream setup for a first time")
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
                self.remoteManager.configureNowPlayingInfo(self.activeTrack)
                break
            case .FsAudioStreamPaused:
                self.remoteManager.configureNowPlayingInfo(self.activeTrack)
                break
            default:
                
                break
            }
        }
    }
    
    func playTrackFromPlaylist(track: EPTrack, playlist: EPMusicPlaylist) {
        if (track.ID != activeTrack.ID){
            setTrack(track)
        }
        
        self.playlist = playlist
    }
    
    
    
    //togglePlayPause
    func togglePlayPause() {
        print("togglePlayPause")
        if (self.audioStream!.isPlaying()) {
            print("pausing")
            self.audioStream!.pause()
            self.delegate?.playbackStatusUpdate(PlaybackStatus.Pause)
        } else {
            print("playing")
            self.audioStream!.pause()
            self.delegate?.playbackStatusUpdate(PlaybackStatus.Play)
        }
        self.remoteManager.configureNowPlayingInfo(activeTrack)
    }
    
    //forward
    func playNextSong() {
        guard let nextTrack = self.playlist.nextTrack() else {
            //handle no previous track found
            return
        }
        setTrack(nextTrack)
    }

    
    //backward
    func playPrevSong() {
        guard let previousTrack = self.playlist.previousTrack() else {
            //handle no previous track found
            return
        }
        setTrack(previousTrack)
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

    func observeRouteChanges() {
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "routeChanged:", name: AVAudioSessionRouteChangeNotification, object: nil)
    }
    
    func routeChanged(notification:NSNotification) {
        print("routeChanged")
        if let userDict = notification.userInfo as? Dictionary<String, AnyObject> {
            if let newValue = userDict[AVAudioSessionRouteChangeReasonKey] as? UInt{
                let reason = AVAudioSessionRouteChangeReason(rawValue: newValue)
                print(reason?.rawValue)
                switch reason! {
                case .NewDeviceAvailable:
                    print("NewDeviceAvailable - connected")
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.audioStream!.isPlaying() == false {
                            self.togglePlayPause()
                        }
                    }
                    
                    break
                    
                case .OldDeviceUnavailable:
                    print("OldDeviceUnavailable - disconnected")
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.audioStream!.isPlaying() == true {
                            self.togglePlayPause()
                        }
                    }
                    
                    break
                    
                default:
                    
                    break
                }

            }
        }
    }
    
    
    func playerItemDidReachEnd(notification: NSNotification) {
        print("song finished playing")
    }
    

}























