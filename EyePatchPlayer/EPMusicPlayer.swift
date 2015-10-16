//
//  EPMusicPlayer.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 17/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import AVFoundation
import StreamingKit

enum PlaybackStatus {
    case Play
    case Pause
    case Unknown
}

class EPMusicPlayer: NSObject, STKAudioPlayerDelegate {
    
    //delegate
    var delegate: EPMusicPlayerDelegate?
    
    //singleton
    static let sharedInstance = EPMusicPlayer()
//    var shuffleOn: Bool = true
    //progress update frequency
    let updateProgressFrequency = 0.1
    var updateProgressTimer: NSTimer?
    //player
    var audioStreamSTK: STKAudioPlayer?

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
        self.setupStream(nil)
        self.observeSessionEvents()
    }
    
    func setTrack(track:EPTrack, force:Bool) {
            self.activeTrack.clearArtworkImage()
            self.playlist.delegate?.playlistDidSetTrackActive(track)
        
            if let cachedTrackInstance = EPCache.trackCachedInstanceForTrack(track) {
                print("cache found")
                self.activeTrack = cachedTrackInstance as EPTrack
            } else {
                print("no cache found")
                self.activeTrack = track
            }
        
        
            if (self.activeTrack.isCached) {
                if (self.activeTrack.hasFileAtPath()) {
                    
                    self.playFromURL(self.activeTrack.URL())
                } else {

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
        
        if EPSettings.shouldBroadcastStatus() { EPHTTPManager.VKBroadcastTrack(self.activeTrack) }
        if EPSettings.shoulScrobbleWithLastFm() { EPHTTPManager.scrobbleTrack(self.activeTrack) }
        
        //should be performed by a separate class
        self.remoteManager.configureNowPlayingInfo(self.activeTrack)
        
        self.resetTimer()
        
        self.delegate?.playbackTrackUpdate()
        
    }
    
    func resetTimer() {
        if ((self.updateProgressTimer) != nil) {
            self.updateProgressTimer?.invalidate()
        }
        
        updateProgressTimer = NSTimer.scheduledTimerWithTimeInterval(updateProgressFrequency, target: self, selector: "updateProgress", userInfo: nil, repeats: true)

    }
    
    
    
    func playTrackFromPlaylist(track: EPTrack, playlist: EPMusicPlaylist) {
        if (track.ID != activeTrack.ID){
            setTrack(track, force: true)
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
            self.play()
            self.delegate?.playbackStatusUpdate(PlaybackStatus.Play)
        }
        self.remoteManager.configureNowPlayingInfo(activeTrack)
    }
    
    //forward
    func playNextSong() {
        print("player: playNextSong")
        guard let nextTrack = self.playlist.nextTrack() else {
            //handle no previous track found
            return
        }
        setTrack(nextTrack, force: true)
    }

    //backward
    func playPrevSong() {
        guard let previousTrack = self.playlist.previousTrack() else {
            //handle no previous track found
            return
        }
        setTrack(previousTrack, force: true)
    }
    
    func observeSessionEvents() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "interruptionEvent:", name: AVAudioSessionInterruptionNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "routeChanged:", name: AVAudioSessionRouteChangeNotification, object: nil)
    }
    
    func interruptionEvent(notification: NSNotification) {
        if notification.name == AVAudioSessionInterruptionNotification {
            if let interruptionType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] {
                
            let interruptionTypeNumber = interruptionType as! NSNumber
                if Int(interruptionTypeNumber) == Int(AVAudioSessionInterruptionType.Began.rawValue) {
                    self.pause()
                } else {
                    self.play()
                }
            }
        }
    }
    
    func routeChanged(notification:NSNotification) {
        print("routeChanged")
        if let userDict = notification.userInfo as? Dictionary<String, AnyObject> {
            if let newValue = userDict[AVAudioSessionRouteChangeReasonKey] as? UInt{
                let reason = AVAudioSessionRouteChangeReason(rawValue: newValue)
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
    
    func setupStream(options:STKAudioPlayerOptions?) {
        print("stream setup for a first time")
        EPAudioSessionManager.initAudioSession()
        if let options = options {
            //with options init
        print(options)
//        self.audioStreamSTK = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
//        let playerOption: STKAudioPlayerOptions = STKAudioPlayerOptions(flushQueueOnSeek: true, enableVolumeMixer: false, equalizerBandFrequencies: (50, 100, 200, 400, 800, 1600, 2600, 16000))
//        self.audioStreamSTK = STKAudioPlayer(options: (STKAudioPlayerOptions){.flushQueueOnSeek = true, .enableVolumeMixer = false, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} })
        } else {
            //no options init
            self.audioStreamSTK = STKAudioPlayer()
        }
        
        self.audioStreamSTK!.delegate = self
        self.audioStreamSTK!.meteringEnabled = true
        self.audioStreamSTK!.volume = 1

    }
    
    func prebufferedPercent() -> Double {
        var prebufferedPercent: Double = 0.0
        
        if self.activeTrack.isCached == false {
            prebufferedPercent = 0.0
        } else {
            prebufferedPercent = 1.0
        }
        
        return prebufferedPercent
    }
    
    func playbackTime() -> Float {
        return Float(self.audioStreamSTK!.progress)
    }
    
    
    func playFromURL(url:NSURL) {
//        self.audioStream!.playFromURL(url)
        self.audioStreamSTK?.playURL(url)
    }
    
    func pause() {
        self.audioStreamSTK?.pause()
    }
    
    func play() {
        self.audioStreamSTK?.resume()
    }
    
    func isPlaying() -> Bool {
        
        switch self.audioStreamSTK!.state {
        case STKAudioPlayerStateReady:
            return false
            
        case STKAudioPlayerStateRunning:
            return true
            
        case STKAudioPlayerStatePlaying:
            return true
            
        case STKAudioPlayerStateBuffering:
            return true
            
        case STKAudioPlayerStatePaused:
            return false
            
        case STKAudioPlayerStateStopped:
            return false
            
        case STKAudioPlayerStateError:
            return false
            
        case STKAudioPlayerStateDisposed:
            return false

            
        default:
            
            break
        }
        
        return true
    }
    
    //STKAudioPlayerDelegate
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, didStartPlayingQueueItemId queueItemId: NSObject!) {
        print("didStartPlayingQueueItemId: \(queueItemId)")
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject!) {
        print("didFinishBufferingSourceWithQueueItemId: \(queueItemId)")
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        
        switch state {
        case STKAudioPlayerStateReady:
            
            break
        case STKAudioPlayerStateRunning, STKAudioPlayerStatePlaying:
            self.delegate?.playbackStatusUpdate(.Play)
            break
        case STKAudioPlayerStateBuffering:
            
            break
        case STKAudioPlayerStatePaused:
            
            break
        case STKAudioPlayerStateStopped:
            
            break
        case STKAudioPlayerStateError:
            
            break
        case STKAudioPlayerStateDisposed:
            
            break
        default:
            break
        }
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, didFinishPlayingQueueItemId queueItemId: NSObject!, withReason stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        switch stopReason {
            
        case STKAudioPlayerStopReasonNone:
            print("STKAudioPlayerStopReasonNone")
            break
        case STKAudioPlayerStopReasonEof:
            print("STKAudioPlayerStopReasonEof")
            self.playNextSong()
            break
        case STKAudioPlayerStopReasonUserAction:
            print("STKAudioPlayerStopReasonUserAction")
            break
        case STKAudioPlayerStopReasonPendingNext:
            print("STKAudioPlayerStopReasonPendingNext")
            break
        case STKAudioPlayerStopReasonDisposed:
            print("STKAudioPlayerStopReasonDisposed")
            break
        case STKAudioPlayerStopReasonError:
            print("STKAudioPlayerStopReasonError")
            break
        default:
             print("STKAudioPlayerStopReasonDefault")
            break
        }
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, logInfo line: String!) {
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, didCancelQueuedItems queuedItems: [AnyObject]!) {
        
    }
}























