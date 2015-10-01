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
                self.configureNowPlayingInfo()
            } else {
                if EPSettings.shouldDownloadArtwork() {
                    EPHTTPManager.getAlbumCoverImage(activeTrack, completion: { (result, image, trackID) -> Void in
                        if result && trackID == self.activeTrack.ID {
                            self.delegate?.trackRetrievedArtworkImage(self.activeTrack.artworkImage()!)
                            self.configureNowPlayingInfo()
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
                        self.configureNowPlayingInfo()
                    }
                })
            }
            self.audioStream!.playFromURL(activeTrack.URL())
        }
        
        if EPSettings.shouldBroadcastStatus() { self.VKBroadcastTrack() }
        if EPSettings.shoulScrobbleWithLastFm() { /*scrobble with LastFm */ }
        
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
        print("broadcasting track")
        let broadcastRequest: VKRequest = VKRequest(method: "audio.setBroadcast", andParameters: ["audio" : "\(activeTrack.ownerID)_\(activeTrack.ID)"], andHttpMethod: "GET")
        broadcastRequest.executeWithResultBlock({ (response) -> Void in
            print("broadcasting track success result: \(response)")
        }, errorBlock: { (error) -> Void in
            print(error)
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
        self.configureNowPlayingInfo()
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
    
    func availableDuration() -> NSTimeInterval {
        return 0
    }
    
    func configureNowPlayingInfo() {
        let info = MPNowPlayingInfoCenter.defaultCenter()
        let newInfo = NSMutableDictionary()
//        let itemProperties:NSSet = NSSet(objects: MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyPlaybackDuration, MPNowPlayingInfoPropertyElapsedPlaybackTime)
        
        newInfo[MPMediaItemPropertyTitle] = activeTrack.title
        newInfo[MPMediaItemPropertyArtist] = activeTrack.artist
        newInfo[MPMediaItemPropertyPlaybackDuration] = activeTrack.duration
        newInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.audioStream!.currentTimePlayed.playbackTimeInSeconds

        if let artworkImage = activeTrack.artworkImage() {
            let artwork = MPMediaItemArtwork(image: artworkImage)
            newInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        info.nowPlayingInfo = newInfo as? [String : AnyObject]
    }

    func playerItemDidReachEnd(notification: NSNotification) {
        print("song finished playing")
    }
    

}
