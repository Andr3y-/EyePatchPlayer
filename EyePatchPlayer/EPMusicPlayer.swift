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
        Performance.measure("chunk 1") { (finishBlock) -> () in
            self.activeTrack.clearArtworkImage()
            self.playlist.delegate?.playlistDidSetTrackActive(track)
            finishBlock()
        }
        
        
        
        Performance.measure("chunk 2") { (finishBlock) -> () in
            if let cachedTrackInstance = EPCache.trackCachedInstanceForTrack(track) {
                print("cache found")
                self.activeTrack = cachedTrackInstance as EPTrack
            } else {
                print("no cache found")
                self.activeTrack = track
            }
            finishBlock()
        }
        
        Performance.measure("chunk 3") { (finishBlock) -> () in
            //this method is taking a whole second to execute
//            self.setupStream()
            finishBlock()
        }
        
        Performance.measure("chunk 4") { (finishBlock) -> () in
            if (self.activeTrack.isCached) {
                if (self.activeTrack.hasFileAtPath()) {
                    //                println("HAS FILE AT PATH, attempting to play from cache:\n\(activeTrack.URL())")
                    self.playFromURL(self.activeTrack.URL())
                } else {
                    //                println("FILE IS MISSING at path, cannot play")
                }
                
                if let _ = self.activeTrack.artworkImage() {
                    self.delegate?.trackRetrievedArtworkImage(self.activeTrack.artworkImage()!)
                    self.remoteManager.configureNowPlayingInfo(self.activeTrack)
                } else {
                    if EPSettings.shouldDownloadArtwork() {
                        EPHTTPManager.getAlbumCoverImage(self.activeTrack, completion: { (result, image, trackID) -> Void in
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
                    EPHTTPManager.getAlbumCoverImage(self.activeTrack, completion: { (result, image, trackID) -> Void in
                        if result == true && trackID == self.activeTrack.ID {
                            self.delegate?.trackRetrievedArtworkImage(self.activeTrack.artworkImage()!)
                            self.remoteManager.configureNowPlayingInfo(self.activeTrack)
                        }
                    })
                }
                self.playFromURL(self.activeTrack.URL())
            }
            finishBlock()
        }
        
        Performance.measure("chunk 5") { (finishBlock) -> () in
            if EPSettings.shouldBroadcastStatus() { EPHTTPManager.VKBroadcastTrack(self.activeTrack) }
            if EPSettings.shoulScrobbleWithLastFm() { EPHTTPManager.scrobbleTrack(self.activeTrack) }
            
            //should be performed by a separate class
            self.remoteManager.configureNowPlayingInfo(self.activeTrack)
            
            self.resetTimer()
            
            self.delegate?.playbackTrackUpdate()
            finishBlock()
        }
        
        
    }
    
    func resetTimer() {
        if ((self.updateProgressTimer) != nil) {
            self.updateProgressTimer?.invalidate()
        }
        
        updateProgressTimer = NSTimer.scheduledTimerWithTimeInterval(updateProgressFrequency, target: self, selector: "updateProgress", userInfo: nil, repeats: true)

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
        if (self.isPlaying()) {
            print("pausing")
            self.pause()
            self.delegate?.playbackStatusUpdate(PlaybackStatus.Pause)
        } else {
            print("playing")
            self.pause()
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
                        if self.isPlaying() == false {
                            self.togglePlayPause()
                        }
                    }
                    
                    break
                    
                case .OldDeviceUnavailable:
                    print("OldDeviceUnavailable - disconnected")
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.isPlaying() == true {
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
    
    //updating playback progress as well as download progress
    func updateProgress() {
        if self.isPlaying() {
            let timeInSeconds = self.playbackTime()

            self.delegate?.playbackProgressUpdate(Int(roundf(timeInSeconds)), bufferedPercent: self.prebufferedPercent())
            
        }
    }
    
    //player library interface
    
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
    
    func prebufferedPercent() -> Double {
        
        var prebufferedPercent: Double = 0.0
        
        if self.audioStream?.cached == false {
            if let contentSize = self.audioStream?.contentLength, contentDownloaded = self.audioStream?.prebufferedByteCount {
                prebufferedPercent = Double(contentDownloaded) / Double(contentSize)
            }
        } else {
            prebufferedPercent = 1.0
        }
        
        return prebufferedPercent
    }
    
    func playbackTime() -> Float {
        return self.audioStream!.currentTimePlayed.playbackTimeInSeconds
    }
    
    
    func playFromURL(url:NSURL) {
        self.audioStream!.playFromURL(url)
    }
    
    func pause() {
        self.audioStream?.pause()
    }
    
    func play() {
        self.audioStream?.play()
    }
    
    func isPlaying() -> Bool {
        return self.audioStream!.isPlaying()
    }
}























