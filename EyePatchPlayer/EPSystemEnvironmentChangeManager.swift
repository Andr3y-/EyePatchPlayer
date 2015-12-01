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
    static var onceToken: dispatch_once_t = 0
    var shouldResumeOnRouteChange = false
    
    override init() {
        super.init()
        print("EPSystemEnvironmentChangeManager init")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "interruptionEvent:", name: AVAudioSessionInterruptionNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "routeChanged:", name: AVAudioSessionRouteChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func interruptionEvent(notification: NSNotification) {
        if notification.name == AVAudioSessionInterruptionNotification {
            if let interruptionType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] {
                
                let interruptionTypeNumber = interruptionType as! NSNumber
                if Int(interruptionTypeNumber) == Int(AVAudioSessionInterruptionType.Began.rawValue) {
                    EPMusicPlayer.sharedInstance.pause()
                } else {
                    EPMusicPlayer.sharedInstance.play()
                }
            }
        }
    }
    
    func routeChanged(notification: NSNotification) {
        print("routeChanged")
        if let userDict = notification.userInfo as? Dictionary<String, AnyObject> {
            if let newValue = userDict[AVAudioSessionRouteChangeReasonKey] as? UInt {
                let reason = AVAudioSessionRouteChangeReason(rawValue: newValue)
                switch reason! {
                case .NewDeviceAvailable:
                    print("NewDeviceAvailable - connected")
                    dispatch_async(dispatch_get_main_queue()) {
                        if EPMusicPlayer.sharedInstance.isPlaying() == false && self.shouldResumeOnRouteChange {
                            EPMusicPlayer.sharedInstance.togglePlayPause()
                            self.shouldResumeOnRouteChange = false
                        }
                    }
                    
                    break
                    
                case .OldDeviceUnavailable:
                    print("OldDeviceUnavailable - disconnected")
                    dispatch_async(dispatch_get_main_queue()) {
                        if EPMusicPlayer.sharedInstance.isPlaying() == true {
                            self.shouldResumeOnRouteChange = true
                            EPMusicPlayer.sharedInstance.togglePlayPause()
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
