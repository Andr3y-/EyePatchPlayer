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
        try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.1)
        } catch _ {
            print("error setting preferred IO buffer duration")
        }
    }
}
