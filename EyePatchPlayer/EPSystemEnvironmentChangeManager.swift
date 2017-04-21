//
//  EPSystemEnvironmentChangeManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 01/12/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import AVFoundation

class EPSystemEnvironmentChangeManager: NSObject {
    
    static let sharedInstance = EPSystemEnvironmentChangeManager()
    static var onceToken: Int = 0
    var shouldResumeOnRouteChange = false
    
    override init() {
        super.init()
        print("EPSystemEnvironmentChangeManager init")
        NotificationCenter.default.addObserver(self, selector: #selector(EPSystemEnvironmentChangeManager.interruptionEvent(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EPSystemEnvironmentChangeManager.routeChanged(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func interruptionEvent(_ notification: Notification) {
        if notification.name == NSNotification.Name.AVAudioSessionInterruption {
            if let interruptionType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] {
                
                let interruptionTypeNumber = interruptionType as! NSNumber
                if Int(interruptionTypeNumber) == Int(AVAudioSessionInterruptionType.began.rawValue) {
                    EPMusicPlayer.sharedInstance.pause()
                } else {
//                    EPMusicPlayer.sharedInstance.play()
                }
            }
        }
    }
    
    func routeChanged(_ notification: Notification) {
        print("routeChanged")
        if let userDict = notification.userInfo as? Dictionary<String, AnyObject> {
            if let newValue = userDict[AVAudioSessionRouteChangeReasonKey] as? UInt {
                let reason = AVAudioSessionRouteChangeReason(rawValue: newValue)
                switch reason! {
                case .newDeviceAvailable:
                    print("NewDeviceAvailable - connected")
//                    dispatch_async(dispatch_get_main_queue()) {
//                        if EPMusicPlayer.sharedInstance.isPlaying() == false && self.shouldResumeOnRouteChange {
//                            EPMusicPlayer.sharedInstance.togglePlayPause()
//                            self.shouldResumeOnRouteChange = false
//                        }
//                    }
                    
                    break
                    
                case .oldDeviceUnavailable:
                    print("OldDeviceUnavailable - disconnected")
                    DispatchQueue.main.async {
                        if EPMusicPlayer.sharedInstance.isPlaying() == true {
                            self.shouldResumeOnRouteChange = true
                            EPMusicPlayer.sharedInstance.pause()
                        }
                    }
                    
                    break
                    
                default:
                    
                    break
                }
                
            }
        }
    }
}
