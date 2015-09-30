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
        print("EPMusicPlayerRemoteManager init")
    }
    
    //remote controls listener
    func registerForRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        commandCenter.playCommand.addTarget(self, action: "remoteCommandReceived:")
        commandCenter.pauseCommand.addTarget(self, action: "remoteCommandReceived:")
        commandCenter.nextTrackCommand.addTarget(self, action: "remoteCommandReceived:")
        commandCenter.previousTrackCommand.addTarget(self, action: "remoteCommandReceived:")
    }
    
    func remoteCommandReceived(object: MPRemoteCommandEvent) {
        print("remote command received by a player object: \(object.command)")
    }
}
