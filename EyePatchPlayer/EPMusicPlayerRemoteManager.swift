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
    override init(){
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
        var newInfo = [String : AnyObject]()
        let newTrack:EPTrack!
        
        if let _ = track {
            newTrack = track!
        } else {
            newTrack = EPMusicPlayer.sharedInstance.activeTrack
        }
        
        newInfo[MPMediaItemPropertyTitle] = newTrack.title
        newInfo[MPMediaItemPropertyArtist] = newTrack.artist
        newInfo[MPMediaItemPropertyPlaybackDuration] = newTrack.duration
        newInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = EPMusicPlayer.sharedInstance.playbackTime()
        
        if let artworkImage = newTrack.artworkImage() {
            let artwork = MPMediaItemArtwork(image: artworkImage)
            newInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        info.nowPlayingInfo = newInfo
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
