//
//  EPAudioSessionManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 12/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import AVFoundation

class EPAudioSessionManager: NSObject {
    class func initAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
            print("error setting session category")
        }

        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
            print("error setting session active")
        }

        do {
            let bufferLength: TimeInterval = 0.1
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(bufferLength)
        } catch _ {
            print("error setting preferred IO buffer duration")
        }
    }
    
    class func setAudioSessionActive(_ active: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(active)
        } catch _ {
            print("error setting session active/deactive")
        }
    }
}
