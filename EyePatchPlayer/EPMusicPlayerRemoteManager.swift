//
//  EPMusicPlayerRemoteManager.swift
//  
//
//  Created by Andr3y on 22/09/2015.
//
//

import UIKit
import MediaPlayer

class EPMusicPlayerRemoteManager: NSObject {
    
    var currentNowPlayingInfo = [String: AnyObject]()
    
    override init() {
        super.init()
        print("EPMusicPlayerRemoteManager init")
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        registerForRemoteCommands()
    }

    //remote controls listener
    func registerForRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        commandCenter.playCommand.addTarget(self, action: "remoteCommandPlay:")
        commandCenter.pauseCommand.addTarget(self, action: "remoteCommandPause:")
        commandCenter.nextTrackCommand.addTarget(self, action: "remoteCommandNext:")
        commandCenter.previousTrackCommand.addTarget(self, action: "remoteCommandPrevious:")
        commandCenter.seekForwardCommand.addTarget(self, action: "seekForwardCommand:")
        commandCenter.seekBackwardCommand.addTarget(self, action: "seekBackwardCommand:")
    }

    func remoteCommandPlay(object: MPRemoteCommandEvent) {
        EPMusicPlayer.sharedInstance.togglePlayPause()
        print(__FUNCTION__)
    }

    func remoteCommandPause(object: MPRemoteCommandEvent) {
        EPMusicPlayer.sharedInstance.togglePlayPause()
        print(__FUNCTION__)
    }

    func remoteCommandNext(object: MPRemoteCommandEvent) {
        EPMusicPlayer.sharedInstance.playNextSong()
        print(__FUNCTION__)
    }

    func remoteCommandPrevious(object: MPRemoteCommandEvent) {
        EPMusicPlayer.sharedInstance.playPrevSong()
        print(__FUNCTION__)
    }

    func configureNowPlayingInfo(track: EPTrack?) {
        
        let info = MPNowPlayingInfoCenter.defaultCenter()
        var newInfo = [String: AnyObject]()
        let newTrack: EPTrack!
        
        if let _ = track {
            newTrack = track!
        } else {
            newTrack = EPMusicPlayer.sharedInstance.activeTrack
        }
        print("configureNowPlayingInfo \(newTrack.title) - \(newTrack.artist)")
        newInfo[MPMediaItemPropertyTitle] = newTrack.title
        newInfo[MPMediaItemPropertyArtist] = newTrack.artist
        newInfo[MPMediaItemPropertyPlaybackDuration] = newTrack.duration
        newInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0

        if let artworkImage = newTrack.artworkImage() {
            let artwork = MPMediaItemArtwork(image: artworkImage)
            newInfo[MPMediaItemPropertyArtwork] = artwork
        } else {
            newInfo[MPMediaItemPropertyArtwork] = nil
        }
        print("newInfo: \(newInfo)")
        currentNowPlayingInfo = newInfo
        info.nowPlayingInfo = currentNowPlayingInfo
        
        self.checkNowPlayingInfoForNewInfoAcceptance()
        
    }

    func checkNowPlayingInfoForNewInfoAcceptance() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            let center = MPNowPlayingInfoCenter.defaultCenter()
            if center.nowPlayingInfo?[MPMediaItemPropertyTitle] as! String != self.currentNowPlayingInfo[MPMediaItemPropertyTitle] as! String &&
                center.nowPlayingInfo?[MPMediaItemPropertyArtist] as! String != self.currentNowPlayingInfo[MPMediaItemPropertyTitle] as! String {
                    print("attempting: center = newInfo")
                    center.nowPlayingInfo = self.currentNowPlayingInfo
                    self.checkNowPlayingInfoForNewInfoAcceptance()
            } else {
                return
            }
        })
    }
    
    func addTrackCoverToNowPlaying(track: EPTrack) {
        if let artworkImage = track.artworkImage() {
            let artwork = MPMediaItemArtwork(image: artworkImage)
            currentNowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = currentNowPlayingInfo
        }
    }
    
    func updatePlaybackStatus() {
        if var newInfo = MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo {
            newInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = EPMusicPlayer.sharedInstance.playbackTime()
            newInfo[MPNowPlayingInfoPropertyPlaybackRate] = EPMusicPlayer.sharedInstance.isPlaying() ? 1.0 : 0.0
            let info = MPNowPlayingInfoCenter.defaultCenter()
            info.nowPlayingInfo = newInfo
        }
    }

    func updatePlaybackTime() {
        if var newInfo = MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo {
            newInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = EPMusicPlayer.sharedInstance.playbackTime()
            let info = MPNowPlayingInfoCenter.defaultCenter()
            info.nowPlayingInfo = newInfo
        }
    }

    func seekForwardCommand(object: MPRemoteCommandEvent) {
        print(__FUNCTION__)
        EPMusicPlayer.sharedInstance.toggleForwardSeek()
    }

    func seekBackwardCommand(object: MPRemoteCommandEvent) {
        print(__FUNCTION__)
        EPMusicPlayer.sharedInstance.toggleBackwardSeek()
    }
}
