//
//  EPSettings.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 23/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

enum EPArtworkSize: Int {
    case Small = 0
    case Medium = 1
    case Large = 2
}

enum EPSettingType: Int {
    case SaveToPlaylist = 0
    case BroadcastStatus = 1
    case ScrobbleWithLastFm = 2
    case ReverseSwipeDirection = 3
    case DownloadArtwork = 4
    case ArtworkSize = 5
    case ShakeToShuffle = 6
    case EqualizerActive = 7
}

class EPSettings: NSUserDefaults {

    class func currentSettingsSet() -> [(type:EPSettingType, value:Any, name:String)] {
        return [
                (.SaveToPlaylist, shouldAutomaticallySaveToPlaylist(), "Save to VK playlist if cached"),
                (.BroadcastStatus, shouldBroadcastStatus(), "VK status broadcast"),
                (.ScrobbleWithLastFm, shouldScrobbleWithLastFm(), "Scrobble with Last.fm"),
                (.ReverseSwipeDirection, isSwipeReverseEnabled(), "Reverse L/R Swipe Direction"),
                (.DownloadArtwork, shouldDownloadArtwork(), "Download artwork"),
                (.ArtworkSize, preferredArtworkSizeEnum(), "Artwork size"),
                (.ShakeToShuffle, shouldDetectShakeToShuffle(), "Shake to Shuffle"),
                (.EqualizerActive, isEqualizerActive(), "Equalizer")
        ]
    }

    class func enabledStatusForSettingType(type: EPSettingType) -> Bool {
        switch type {
        case .ScrobbleWithLastFm:
            return true

        default:
            return true
        }
    }

    class func changeSetting(type: EPSettingType, value: AnyObject?) -> AnyObject {

        switch type {
        case .SaveToPlaylist:

            let specificValue: Bool!
            if value != nil {
                specificValue = value! as! Bool
            } else {
                specificValue = !shouldAutomaticallySaveToPlaylist()
            }

            NSUserDefaults.standardUserDefaults().setObject(specificValue, forKey: "SaveToPlaylist")
            shouldAutomaticallySaveToPlaylistValue = specificValue
            return shouldAutomaticallySaveToPlaylistValue!

        case .BroadcastStatus:

            let specificValue: Bool!
            if value != nil {
                specificValue = value! as! Bool
            } else {
                specificValue = !shouldBroadcastStatus()
            }

            NSUserDefaults.standardUserDefaults().setBool(specificValue, forKey: "BroadcastStatus")
            shouldBroadcastStatusValue = specificValue
            return (specificValue)

        case .ShakeToShuffle:

            let specificValue: Bool!
            if value != nil {
                specificValue = value! as! Bool
            } else {
                specificValue = !shouldDetectShakeToShuffle()
            }

            NSUserDefaults.standardUserDefaults().setBool(specificValue, forKey: "ShakeToShuffle")
            shouldDetectShakeToShuffleValue = specificValue
            return (specificValue)

        case .ScrobbleWithLastFm:

            let specificValue: Bool!
            if value != nil {
                specificValue = value! as! Bool
            } else {
                specificValue = !shouldScrobbleWithLastFm()
            }

            NSUserDefaults.standardUserDefaults().setBool(specificValue, forKey: "ScrobbleWithLastFm")
            shouldScrobbleWithLastFmValue = specificValue
            return (specificValue)

        case .ReverseSwipeDirection:
            
            let specificValue: Bool!
            if value != nil {
                specificValue = value! as! Bool
            } else {
                specificValue = !isSwipeReverseEnabled()
            }
            
            NSUserDefaults.standardUserDefaults().setBool(specificValue, forKey: "SwipeReverseEnabled")
            isSwipeReverseEnabledValue = specificValue
            return (specificValue)
            
        case .DownloadArtwork:

            let specificValue: Bool!
            if value != nil {
                specificValue = value! as! Bool
            } else {
                specificValue = !shouldDownloadArtwork()
            }

            NSUserDefaults.standardUserDefaults().setBool(specificValue, forKey: "DownloadArtwork")
            shouldDownloadArtworkValue = specificValue
            return (specificValue)

        case .EqualizerActive:

            let specificValue: Bool!
            if value != nil {
                specificValue = value! as! Bool
            } else {
                specificValue = !isEqualizerActive()
            }
            EPMusicPlayer.sharedInstance.audioStreamSTK?.equalizerEnabled = specificValue
            NSUserDefaults.standardUserDefaults().setBool(specificValue, forKey: "EQActive")
            isEqualizerActiveValue = specificValue
            return (specificValue)

        case .ArtworkSize:

            let specificValue: EPArtworkSize!
            if value != nil {
                specificValue = value! as! EPArtworkSize
            } else {
                specificValue = nextArtworkSizeEnum(preferredArtworkSizeEnum())
            }

            let value = specificValue
            NSUserDefaults.standardUserDefaults().setObject(value.rawValue, forKey: "ArtworkSize")
            preferredArtworkSizeEnumValue = value
            return preferredArtworkSizeString()
        }
    }

    static var shouldAutomaticallySaveToPlaylistValue: Bool?
    class func shouldAutomaticallySaveToPlaylist() -> Bool {
        //read from NSUserDefaults()
        if let value = shouldAutomaticallySaveToPlaylistValue {
            return value
        } else {

            if let value = NSUserDefaults.standardUserDefaults().objectForKey("SaveToPlaylist") as? Bool {
                shouldAutomaticallySaveToPlaylistValue = value
                return shouldAutomaticallySaveToPlaylistValue!
            } else {
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "SaveToPlaylist")
                shouldAutomaticallySaveToPlaylistValue = true
                return shouldAutomaticallySaveToPlaylistValue!
            }
        }
    }

    static var shouldBroadcastStatusValue: Bool?
    class func shouldBroadcastStatus() -> (Bool) {
        //read from NSUserDefaults()
        if let value = shouldBroadcastStatusValue {
            return value
        } else {

            if let value = NSUserDefaults.standardUserDefaults().objectForKey("BroadcastStatus") as? Bool {
                shouldBroadcastStatusValue = value
                return shouldBroadcastStatusValue!
            } else {
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "BroadcastStatus")
                shouldBroadcastStatusValue = true
                return shouldBroadcastStatusValue!
            }
        }
    }

    static var shouldDetectShakeToShuffleValue: Bool?
    class func shouldDetectShakeToShuffle() -> (Bool) {
        //read from NSUserDefaults()
        if let value = shouldDetectShakeToShuffleValue {
            return value
        } else {

            if let value = NSUserDefaults.standardUserDefaults().objectForKey("ShakeToShuffle") as? Bool {
                shouldDetectShakeToShuffleValue = value
                return shouldDetectShakeToShuffleValue!
            } else {
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "ShakeToShuffle")
                shouldDetectShakeToShuffleValue = true
                return shouldDetectShakeToShuffleValue!
            }
        }
    }

    static var shouldScrobbleWithLastFmValue: Bool?
    class func shouldScrobbleWithLastFm() -> (Bool) {
        //read from NSUserDefaults()
        if let value = shouldScrobbleWithLastFmValue {
            return value
        } else {

            if let value = NSUserDefaults.standardUserDefaults().objectForKey("ScrobbleWithLastFm") as? Bool {
                if lastfmMobileSession().characters.count == 0 {
                    NSUserDefaults.standardUserDefaults().setObject(false, forKey: "ScrobbleWithLastFm")
                    shouldScrobbleWithLastFmValue = false
                    return shouldScrobbleWithLastFmValue!
                } else {
                    shouldScrobbleWithLastFmValue = value
                    return shouldScrobbleWithLastFmValue!
                }

            } else {
                NSUserDefaults.standardUserDefaults().setObject(false, forKey: "ScrobbleWithLastFm")
                shouldScrobbleWithLastFmValue = false
                return shouldScrobbleWithLastFmValue!
            }
        }
    }

    static var isSwipeReverseEnabledValue: Bool?
    class func isSwipeReverseEnabled() -> (Bool) {
        //read from NSUserDefaults()
        if let value = isSwipeReverseEnabledValue {
            return value
        } else {
            
            if let value = NSUserDefaults.standardUserDefaults().objectForKey("SwipeReverseEnabled") as? Bool {
                isSwipeReverseEnabledValue = value
                return isSwipeReverseEnabledValue!
            } else {
                NSUserDefaults.standardUserDefaults().setObject(false, forKey: "SwipeReverseEnabled")
                isSwipeReverseEnabledValue = false
                return isSwipeReverseEnabledValue!
            }
        }
    }
    
    static var shouldDownloadArtworkValue: Bool?
    class func shouldDownloadArtwork() -> (Bool) {
        //read from NSUserDefaults()
        if let value = shouldDownloadArtworkValue {
            return value
        } else {

            if let value = NSUserDefaults.standardUserDefaults().objectForKey("DownloadArtwork") as? Bool {
                shouldDownloadArtworkValue = value
                return shouldDownloadArtworkValue!
            } else {
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "DownloadArtwork")
                shouldDownloadArtworkValue = true
                return shouldDownloadArtworkValue!
            }
        }
    }

    static var preferredArtworkSizeEnumValue: EPArtworkSize?
    private class func preferredArtworkSizeEnum() -> EPArtworkSize {
        //read from NSUserDefaults()
        if let value = preferredArtworkSizeEnumValue {
            return value
        } else {

            if let value = NSUserDefaults.standardUserDefaults().objectForKey("ArtworkSize") as? EPArtworkSize.RawValue {
                preferredArtworkSizeEnumValue = EPArtworkSize(rawValue: value)
                return preferredArtworkSizeEnumValue!
            } else {
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "ArtworkSize")
                preferredArtworkSizeEnumValue = EPArtworkSize.Large
                return preferredArtworkSizeEnumValue!
            }
        }
    }

    static var isEqualizerActiveValue: Bool?
    class func isEqualizerActive() -> (Bool) {
        //read from NSUserDefaults()
        if let value = isEqualizerActiveValue {
            return value
        } else {

            if let value = NSUserDefaults.standardUserDefaults().objectForKey("EQActive") as? Bool {
                isEqualizerActiveValue = value
                return isEqualizerActiveValue!
            } else {
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "EQActive")
                isEqualizerActiveValue = true
                return isEqualizerActiveValue!
            }
        }
    }

    static var lastfmMobileSessionValue: String?
    class func lastfmMobileSession() -> (String) {
        //read from NSUserDefaults()
        if let value = lastfmMobileSessionValue {
            return value
        } else {

            if let value = NSUserDefaults.standardUserDefaults().objectForKey("LastfmSession") as? String {
                lastfmMobileSessionValue = value
                return lastfmMobileSessionValue!
            } else {
                NSUserDefaults.standardUserDefaults().setObject("", forKey: "LastfmSession")
                lastfmMobileSessionValue = ""
                return lastfmMobileSessionValue!
            }
        }
    }

    class func setLastfmSession(sessionString: String) {
        NSUserDefaults.standardUserDefaults().setObject(sessionString, forKey: "LastfmSession")
        lastfmMobileSessionValue = sessionString
    }

    class func nextArtworkSizeEnum(current: EPArtworkSize) -> EPArtworkSize {
        switch current {
        case .Small:
            return .Medium
        case .Medium:
            return .Large
        case .Large:
            return .Small
        }
    }

    //misc
    class func preferredArtworkSizeString() -> String {

        switch EPSettings.preferredArtworkSizeEnum() {
        case .Small:
            return "200x200"

        case .Medium:
            return "400x400"

        case .Large:
            return "600x600"
        }
    }

    class func loadEQSettings() -> [Double] {
        if let EQGains = NSUserDefaults.standardUserDefaults().objectForKey("EQGains") as? [Double] {
            return EQGains
        } else {

            let EQGains = [
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0
            ]

            NSUserDefaults.standardUserDefaults().setObject(EQGains, forKey: "EQGains")

            return EQGains
        }
    }
}
