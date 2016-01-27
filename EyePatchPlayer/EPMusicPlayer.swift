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

enum SeekStatus {
    case None
    case Forward
    case Backward
}

class EPMusicPlayer: NSObject, STKAudioPlayerDelegate {

    //delegate
    weak var delegate: EPMusicPlayerDelegate?

    //singleton
    static let sharedInstance = EPMusicPlayer()
    //progress update frequency
    let updateProgressFrequency = 0.1
    var updateProgressTimer: NSTimer?
    //player
    var audioStreamSTK: STKAudioPlayer?

    //remote manager
    var remoteManager: EPMusicPlayerRemoteManager!
    //seeking variable
    var seekStatus = SeekStatus.None
    let seekingInterval: UInt64 = 3
    let seekingFrequency = 0.2
    //playlist & current song
    var playlist: EPMusicPlaylist = EPMusicPlaylist()
    //scrobbling 
    var scrobblingComplete = false

    private(set) internal var activeTrack: EPTrack = EPTrack() {
        didSet {
            print("activeTrack didSet: \(activeTrack.artist) - \(activeTrack.title)\n\(activeTrack.URL())")
        }
    }

    override init() {
        super.init()

        self.remoteManager = EPMusicPlayerRemoteManager()

        let equalizerB: (Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32) = (50, 100, 200, 400, 800, 1600, 2600, 16000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        let options: STKAudioPlayerOptions = STKAudioPlayerOptions(flushQueueOnSeek: true, enableVolumeMixer: true, equalizerBandFrequencies: equalizerB, readBufferSize: 0, bufferSizeInSeconds: 0, secondsRequiredToStartPlaying: 0, gracePeriodAfterSeekInSeconds: 0, secondsRequiredToStartPlayingAfterBufferUnderun: 0)

        self.setupStream(options)
        EPSystemEnvironmentChangeManager.sharedInstance
    }

    func setupStream(options: STKAudioPlayerOptions?) {
        print("stream setup for a first time")
        EPAudioSessionManager.initAudioSession()
        if let options = options {
            //with options init
            print(options)
            
            self.audioStreamSTK = STKAudioPlayer(options: options)
            
            self.audioStreamSTK?.equalizerEnabled = EPSettings.isEqualizerActive()
            
            let EQGains = EPSettings.loadEQSettings()
            
            self.audioStreamSTK!.setGain(Float(EQGains[0]), forEqualizerBand: 0)
            self.audioStreamSTK!.setGain(Float(EQGains[1]), forEqualizerBand: 1)
            self.audioStreamSTK!.setGain(Float(EQGains[2]), forEqualizerBand: 2)
            self.audioStreamSTK!.setGain(Float(EQGains[3]), forEqualizerBand: 3)
            self.audioStreamSTK!.setGain(Float(EQGains[4]), forEqualizerBand: 4)
            self.audioStreamSTK!.setGain(Float(EQGains[5]), forEqualizerBand: 5)
            self.audioStreamSTK!.setGain(Float(EQGains[6]), forEqualizerBand: 6)
            self.audioStreamSTK!.setGain(Float(EQGains[7]), forEqualizerBand: 7)
            
        } else {
            //no options init
            self.audioStreamSTK = STKAudioPlayer()
        }
        
        self.audioStreamSTK!.delegate = self
        self.audioStreamSTK!.meteringEnabled = true
        self.audioStreamSTK!.volume = 1
        
    }
    
    func loadDataFromCache(completion: ((result:Bool) -> Void)?) {
        if let (track, playlist) = EPCache.cacheStateUponLaunch() {
            print("player loaded playlist + track from last session")
            self.playTrackFromPlaylist(track, playlist: playlist)
            self.pause()
            if completion != nil {
                completion!(result: true)
            }
        } else {
            EPHTTPManager.retrievePlaylistOfUserWithID(nil, count: 5, completion: {
                (result, playlist) -> Void in
                if result {
                    if let playlist = playlist, let firstTrack = playlist.tracks.first where playlist.tracks.count > 0 {
                        self.playTrackFromPlaylist(firstTrack, playlist: playlist)
                        self.pause()
                        if completion != nil {
                            completion!(result: true)
                        }
                    } else {
                        //  Either no playlist or playlist is empty
                        let playlist = EPMusicPlaylist(tracks: [EPTrack.defaultTrack()])
                        self.playTrackFromPlaylist(playlist.tracks.first!, playlist: playlist)
                        self.pause()
                        if completion != nil {
                            completion!(result: true)
                        }
                    }
                }
            })
        }
    }
    
    //main method for setting track to be played
    
    func setTrack(track: EPTrack, force: Bool) {

        self.activeTrack.clearArtworkImage()
        self.playlist.delegate?.playlistDidSetTrackActive(track)

        if let cachedTrackInstance = EPCache.trackCachedInstanceForTrack(track) {
            print("cache found")
            self.activeTrack = cachedTrackInstance as EPTrack
        } else {
            print("no cache found")
            self.activeTrack = track
        }
        
        self.remoteManager.configureNowPlayingInfo(self.activeTrack)

        if hasEmergencyTrackActive() {
            return
        }

        if (self.activeTrack.isCached) {
            if (self.activeTrack.hasFileAtPath()) {

                self.playFromURL(self.activeTrack.URL())
            } else {

            }

            if let _ = self.activeTrack.artworkImage() {
                self.delegate?.trackRetrievedArtworkImage(self.activeTrack.artworkImage()!)
//artwork should be already set
//                self.remoteManager.addTrackCoverToNowPlaying(self.activeTrack)

            } else {
                if EPSettings.shouldDownloadArtwork() {
                    EPHTTPManager.getAlbumCoverImage(self.activeTrack, completion: {
                        (result, image, trackID) -> Void in
                        if result && trackID == self.activeTrack.ID {
                            self.delegate?.trackRetrievedArtworkImage(self.activeTrack.artworkImage()!)
                            self.remoteManager.addTrackCoverToNowPlaying(self.activeTrack)
                        }
                    })
                }
            }

        } else {
            if EPSettings.shouldDownloadArtwork() {
                EPHTTPManager.getAlbumCoverImage(self.activeTrack, completion: {
                    (result, image, trackID) -> Void in
                    if result == true && trackID == self.activeTrack.ID {
                        self.delegate?.trackRetrievedArtworkImage(self.activeTrack.artworkImage()!)
                        self.remoteManager.addTrackCoverToNowPlaying(self.activeTrack)
                    }
                })
            }
            self.playFromURL(self.activeTrack.URL())
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            if !track.invalidated && track.ID == self.activeTrack.ID && self.isPlaying() {
                if EPSettings.shouldBroadcastStatus() {
                    EPHTTPManager.VKBroadcastTrack(self.activeTrack)
                    EPHTTPManager.lastfmBroadcastTrack(self.activeTrack, completion: nil)
                }
                    
                EPInternalScrobbleManager.enqueueTrackForScrobbling(self.activeTrack)
            }
        }

        self.scrobblingComplete = false

        //should be performed by a separate class

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
        self.playlist = playlist

        if (track.ID != activeTrack.ID) {
            setTrack(track, force: true)
        }
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

        self.remoteManager.updatePlaybackStatus()
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

        if playbackTime() > 3 && self.isPlaying() && self.activeTrack.duration > 10 {
            self.audioStreamSTK?.seekToTime(0)
            self.delegate?.playbackProgressUpdate(0, bufferedPercent: 0)
            self.remoteManager.updatePlaybackTime()//configureNowPlayingInfo(self.activeTrack)
            return
        }

        guard let previousTrack = self.playlist.previousTrack() else {
            //handle no previous track found
            return
        }
        setTrack(previousTrack, force: true)
    }

//    func playerItemDidReachEnd(notification: NSNotification) {
//        print("song finished playing")
//    }

    //updating playback progress as well as download progress
    func updateProgress() {
        if self.isPlaying() || self.seekStatus != .None {
            let timeInSeconds = self.playbackTime()
            //scrobbling logic
            if EPSettings.shouldScrobbleWithLastFm() && !self.scrobblingComplete && Double(timeInSeconds) > Double(self.activeTrack.duration) * EPLastFMScrobbleManager.playbackPercentCompleteToScrobble {
                EPLastFMScrobbleManager.enqueueTrackForScrobbling(self.activeTrack)
                self.scrobblingComplete = true
            }
            self.delegate?.playbackProgressUpdate(Int(roundf(timeInSeconds)), bufferedPercent: self.prebufferedPercent())
        }
    }

    //player library interface

   

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


    func playFromURL(url: NSURL) {
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

    func toggleForwardSeek() {
        if self.seekStatus == .None {
            self.seekStatus = .Forward
            self.seekForward()
            return
        }

        if self.seekStatus == .Forward {
            self.seekStatus = .None
        }
    }

    func toggleBackwardSeek() {
        if self.seekStatus == .None {
            self.seekStatus = .Backward
            self.seekBackward()
            return
        }

        if self.seekStatus == .Backward {
            self.seekStatus = .None
        }
    }

    private func seekForward() {
        print("seekForward status:\(self.seekStatus)")
        if self.seekStatus != .Forward {
            return
        }
        print("+\(seekingInterval)")
        self.audioStreamSTK?.seekToTime(min(self.audioStreamSTK!.progress + Double(seekingInterval), self.audioStreamSTK!.duration))
        self.remoteManager.updatePlaybackTime()
        if !self.isPlaying() {
            self.updateProgress()
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seekingFrequency * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.seekForward()
        })

    }

    private func seekBackward() {
        print("seekBackward status:\(self.seekStatus)")
        if self.seekStatus != .Backward {
            return
        }
        print("-\(seekingInterval)")
        self.audioStreamSTK?.seekToTime(max(self.audioStreamSTK!.progress - Double(seekingInterval), 0))
        self.remoteManager.updatePlaybackTime()
        if !self.isPlaying() {
            self.updateProgress()
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seekingFrequency * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.seekBackward()
        })
    }

    func seekToProgress(progress: Float) {
        self.audioStreamSTK?.seekToTime(Double(activeTrack.duration) * Double(progress))
        self.remoteManager.updatePlaybackTime()
        self.updateProgress()
    }
    
    func setEqualizerEnabled(value: Bool) {
        self.audioStreamSTK?.equalizerEnabled = value
    }
    
    //STKAudioPlayerDelegate
    func audioPlayer(audioPlayer: STKAudioPlayer!, didStartPlayingQueueItemId queueItemId: NSObject!) {
        print("didStartPlayingQueueItemId: \(queueItemId)")
        self.remoteManager.updatePlaybackTime()
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
            if self.playbackTime() / Float(self.activeTrack.duration) > 0.95 {
                self.playNextSong()
            }
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

    func hasEmergencyTrackActive() -> Bool {
        if self.activeTrack.title == "No Track Selected" || self.activeTrack.URLString == "" {
            return true
        } else {
            return false
        }
    }
}























