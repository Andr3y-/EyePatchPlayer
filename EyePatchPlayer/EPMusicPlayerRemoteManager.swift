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
        UIApplication.shared.beginReceivingRemoteControlEvents()
        registerForRemoteCommands()
    }

    //remote controls listener
    func registerForRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget(self, action: #selector(remoteCommandPlay))
        commandCenter.pauseCommand.addTarget(self, action: #selector(remoteCommandPause))
        commandCenter.togglePlayPauseCommand.addTarget(self, action: #selector(remoteCommandTogglePlayback))
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(remoteCommandNext))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(remoteCommandPrevious))
        commandCenter.seekForwardCommand.addTarget(self, action: #selector(seekForwardCommand))
        commandCenter.seekBackwardCommand.addTarget(self, action: #selector(seekBackwardCommand))
    }

    func remoteCommandPlay(_ object: MPRemoteCommandEvent) {
        EPMusicPlayer.sharedInstance.togglePlayPause()
        print(#function)
    }

    func remoteCommandTogglePlayback(_ object: MPRemoteCommandEvent) {
        EPMusicPlayer.sharedInstance.togglePlayPause()
    }
    
    func remoteCommandPause(_ object: MPRemoteCommandEvent) {
        EPMusicPlayer.sharedInstance.togglePlayPause()
        print(#function)
    }

    func remoteCommandNext(_ object: MPRemoteCommandEvent) {
        EPMusicPlayer.sharedInstance.playNextSong()
        print(#function)
    }

    func remoteCommandPrevious(_ object: MPRemoteCommandEvent) {
        EPMusicPlayer.sharedInstance.playPrevSong()
        print(#function)
    }

    func configureNowPlayingInfo(_ track: EPTrack?) {
        
        let info = MPNowPlayingInfoCenter.default()
        var newInfo = [String: AnyObject]()
        let newTrack: EPTrack!
        
        if let _ = track {
            newTrack = track!
        } else {
            newTrack = EPMusicPlayer.sharedInstance.activeTrack
        }
        print("configureNowPlayingInfo \(newTrack.title) - \(newTrack.artist)")
        newInfo[MPMediaItemPropertyTitle] = newTrack.title as AnyObject?
        newInfo[MPMediaItemPropertyArtist] = newTrack.artist as AnyObject?
        newInfo[MPMediaItemPropertyPlaybackDuration] = newTrack.duration as AnyObject?
        newInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0 as AnyObject?

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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            let center = MPNowPlayingInfoCenter.default()
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
    
    func addTrackCoverToNowPlaying(_ track: EPTrack) {
        if let artworkImage = track.artworkImage() {
            let artwork = MPMediaItemArtwork(image: artworkImage)
            currentNowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            MPNowPlayingInfoCenter.default().nowPlayingInfo = currentNowPlayingInfo
        }
    }
    
    func updatePlaybackStatus() {
        if var newInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            newInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = EPMusicPlayer.sharedInstance.playbackTime()
            newInfo[MPNowPlayingInfoPropertyPlaybackRate] = EPMusicPlayer.sharedInstance.isPlaying() ? 1.0 : 0.0
            let info = MPNowPlayingInfoCenter.default()
            info.nowPlayingInfo = newInfo
        }
    }

    func updatePlaybackTime() {
        if var newInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            newInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = EPMusicPlayer.sharedInstance.playbackTime()
            let info = MPNowPlayingInfoCenter.default()
            info.nowPlayingInfo = newInfo
        }
    }

    func seekForwardCommand(_ object: MPRemoteCommandEvent) {
        print(#function)
        EPMusicPlayer.sharedInstance.toggleForwardSeek()
    }

    func seekBackwardCommand(_ object: MPRemoteCommandEvent) {
        print(#function)
        EPMusicPlayer.sharedInstance.toggleBackwardSeek()
    }
}
