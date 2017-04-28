//
//  EPMusicPlayer.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 17/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import AVFoundation
import StreamingKitWrapper

enum PlaybackStatus {
    case play
    case pause
    case unknown
}

enum SeekStatus {
    case none
    case forward
    case backward
}

class EPMusicPlayer: NSObject, STKAudioPlayerDelegate {

    //delegate
    weak var delegate: EPMusicPlayerDelegate?

    //singleton
    static let sharedInstance = EPMusicPlayer()
    //progress update frequency
    let updateProgressFrequency = 0.1
    var updateProgressTimer: Timer?
    //player
    var audioStreamSTK: STKAudioPlayer?

    //remote manager
    var remoteManager: EPMusicPlayerRemoteManager!
    //seeking variable
    var seekStatus = SeekStatus.none
    let seekingInterval: UInt64 = 3
    let seekingFrequency = 0.2
    //playlist & current song
    var playlist: EPMusicPlaylist = EPMusicPlaylist()
    //scrobbling 
    var scrobblingComplete = false
    var repeatOn = false {
        didSet {
            print("player: repeat is now: \(repeatOn)")
        }
    }
    
    fileprivate(set) internal var activeTrack: EPTrack = EPTrack() {
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
        let _ = EPSystemEnvironmentChangeManager.sharedInstance
    }

    func setupStream(_ options: STKAudioPlayerOptions?) {
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
    
    func loadDataFromCache(_ completion: ((_ result:Bool) -> Void)?) {
        if let (track, playlist) = EPCache.cacheStateUponLaunch() {
            print("player loaded playlist + track from last session")
            self.playTrackFromPlaylist(track, playlist: playlist)
            self.pause()
            if completion != nil {
                completion!(true)
            }
        } else {
            //  Either no playlist or playlist is empty
            let playlist = EPMusicPlaylist(tracks: [EPTrack.defaultTrack()])
            self.playTrackFromPlaylist(playlist.tracks.first!, playlist: playlist)
            self.pause()
            if completion != nil {
                completion!(true)
            }
        }
    }

    //main method for setting track to be played

    func setTrack(_ track: EPTrack, force: Bool) {

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

                self.playFromURL(self.activeTrack.URL() as URL)
            } else {

            }

            if let _ = self.activeTrack.artworkImage() {
                self.delegate?.trackRetrievedArtworkImage(self.activeTrack.artworkImage()!)
//artwork should be already set
//                self.remoteManager.addTrackCoverToNowPlaying(self.activeTrack)

            } else {
                if EPSettings.shouldDownloadArtwork() {
                    EPHTTPTrackMetadataManager.getAlbumCoverImage(self.activeTrack, completion: {
                        (result, image, trackUniqueID) -> Void in
                        if result && trackUniqueID == self.activeTrack.uniqueID {
                            self.delegate?.trackRetrievedArtworkImage(self.activeTrack.artworkImage()!)
                            self.remoteManager.addTrackCoverToNowPlaying(self.activeTrack)
                        }
                    })
                }
            }

        } else {
            if EPSettings.shouldDownloadArtwork() {
                EPHTTPTrackMetadataManager.getAlbumCoverImage(self.activeTrack, completion: {
                    (result, image, trackUniqueID) -> Void in
                    if result == true && trackUniqueID == self.activeTrack.uniqueID {
                        self.delegate?.trackRetrievedArtworkImage(self.activeTrack.artworkImage()!)
                        self.remoteManager.addTrackCoverToNowPlaying(self.activeTrack)
                    }
                })
            }
            self.playFromURL(self.activeTrack.URL() as URL)
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            if !track.isInvalidated && track.uniqueID == self.activeTrack.uniqueID && self.isPlaying() {
                EPHTTPLastFMManager.broadcastTrack(self.activeTrack, completion: nil)

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

        updateProgressTimer = Timer.scheduledTimer(timeInterval: updateProgressFrequency, target: self, selector: #selector(EPMusicPlayer.updateProgress), userInfo: nil, repeats: true)

    }

    func playTrackFromPlaylist(_ track: EPTrack, playlist: EPMusicPlaylist) {
        self.playlist = playlist

        if (track.uniqueID != activeTrack.uniqueID) {
            setTrack(track, force: true)
        }
    }

    //togglePlayPause
    func togglePlayPause() {

        if (self.isPlaying()) {
            print("pausing")
            self.pause()
            EPAudioSessionManager.setAudioSessionActive(false)
        } else {
            print("playing")
            self.play()
            EPAudioSessionManager.setAudioSessionActive(true)
        }
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
            self.audioStreamSTK?.seek(toTime: 0)
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

    func repeatTrack() {
        self.setTrack(self.activeTrack, force: true)
    }

    //updating playback progress as well as download progress
    func updateProgress() {
        if self.isPlaying() || self.seekStatus != .none {
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


    func playFromURL(_ url: URL) {
//        self.audioStream!.playFromURL(url)
        self.audioStreamSTK?.play(url)
    }

    func pause() {
        self.audioStreamSTK?.pause()
        self.delegate?.playbackStatusUpdate(PlaybackStatus.pause)
        self.remoteManager.updatePlaybackStatus()
    }

    func play() {
        self.audioStreamSTK?.resume()
        self.remoteManager.updatePlaybackStatus()
    }

    func isPlaying() -> Bool {

        switch self.audioStreamSTK!.state {
        case STKAudioPlayerState():
            return false

        case STKAudioPlayerState.running:
            return true

        case STKAudioPlayerState.playing:
            return true

        case STKAudioPlayerState.buffering:
            return true

        case STKAudioPlayerState.paused:
            return false

        case STKAudioPlayerState.stopped:
            return false

        case STKAudioPlayerState.error:
            return false

        case STKAudioPlayerState.disposed:
            return false


        default:

            break
        }

        return true
    }

    func toggleForwardSeek() {
        if self.seekStatus == .none {
            self.seekStatus = .forward
            self.seekForward()
            return
        }

        if self.seekStatus == .forward {
            self.seekStatus = .none
        }
    }

    func toggleBackwardSeek() {
        if self.seekStatus == .none {
            self.seekStatus = .backward
            self.seekBackward()
            return
        }

        if self.seekStatus == .backward {
            self.seekStatus = .none
        }
    }

    fileprivate func seekForward() {
        print("seekForward status:\(self.seekStatus)")
        if self.seekStatus != .forward {
            return
        }
        print("+\(seekingInterval)")
        self.audioStreamSTK?.seek(toTime: min(self.audioStreamSTK!.progress + Double(seekingInterval), self.audioStreamSTK!.duration))
        self.remoteManager.updatePlaybackTime()
        if !self.isPlaying() {
            self.updateProgress()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(seekingFrequency * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.seekForward()
        })

    }

    fileprivate func seekBackward() {
        print("seekBackward status:\(self.seekStatus)")
        if self.seekStatus != .backward {
            return
        }
        print("-\(seekingInterval)")
        self.audioStreamSTK?.seek(toTime: max(self.audioStreamSTK!.progress - Double(seekingInterval), 0))
        self.remoteManager.updatePlaybackTime()
        if !self.isPlaying() {
            self.updateProgress()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(seekingFrequency * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.seekBackward()
        })
    }

    func seekToProgress(_ progress: Float) {
        self.audioStreamSTK?.seek(toTime: Double(activeTrack.duration) * Double(progress))
        self.remoteManager.updatePlaybackTime()
        self.updateProgress()
    }
    
    func setEqualizerEnabled(_ value: Bool) {
        self.audioStreamSTK?.equalizerEnabled = value
    }
    
    //STKAudioPlayerDelegate
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        print("didStartPlayingQueueItemId: \(queueItemId)")
        self.remoteManager.updatePlaybackTime()
    }

    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        print("didFinishBufferingSourceWithQueueItemId: \(queueItemId)")
    }

    func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {

        switch state {
        case STKAudioPlayerState():

            break
        case STKAudioPlayerState.running, STKAudioPlayerState.playing:
            self.delegate?.playbackStatusUpdate(.play)
            break
        case STKAudioPlayerState.buffering:

            break
        case STKAudioPlayerState.paused:

            break
        case STKAudioPlayerState.stopped:

            break
        case STKAudioPlayerState.error:

            break
        case STKAudioPlayerState.disposed:

            break
        default:
            break
        }

    }

    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        switch stopReason {

        case STKAudioPlayerStopReason.none:
            print("STKAudioPlayerStopReasonNone")
            if self.playbackTime() / Float(self.activeTrack.duration) > 0.95 {
                if self.repeatOn {
                    self.repeatTrack()
                } else {
                    self.playNextSong()
                }
                
            }
            break
        case STKAudioPlayerStopReason.eof:
            print("STKAudioPlayerStopReasonEof")
            if self.repeatOn {
                self.repeatTrack()
            } else {
                self.playNextSong()
            }
            
            break
        case STKAudioPlayerStopReason.userAction:
            print("STKAudioPlayerStopReasonUserAction")
            break
        case STKAudioPlayerStopReason.pendingNext:
            print("STKAudioPlayerStopReasonPendingNext")
            break
        case STKAudioPlayerStopReason.disposed:
            print("STKAudioPlayerStopReasonDisposed")
            break
        case STKAudioPlayerStopReason.error:
            print("STKAudioPlayerStopReasonError")
            break
        }
    }

    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {

    }

    func audioPlayer(_ audioPlayer: STKAudioPlayer, logInfo line: String) {

    }

    private func audioPlayer(_ audioPlayer: STKAudioPlayer, didCancelQueuedItems queuedItems: [AnyObject]) {

    }

    func hasEmergencyTrackActive() -> Bool {
        if self.activeTrack.title == "No Track Selected" || self.activeTrack.URLString == "" {
            return true
        } else {
            return false
        }
    }
}























