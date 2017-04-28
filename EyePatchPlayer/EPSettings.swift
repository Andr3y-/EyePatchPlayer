//
//  EPSettings.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 23/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

enum EPArtworkSize: Int {
    case small = 0
    case medium = 1
    case large = 2
}

enum EPSettingType: Int {
    case scrobbleWithLastFm = 2
    case reverseSwipeDirection = 3
    case downloadArtwork = 4
    case artworkSize = 5
    case shakeToShuffle = 6
    case equalizerActive = 7
}

class EPSettings: UserDefaults {

    class func currentSettingsSet() -> [(type:EPSettingType, value:Any, name:String)] {
        return [
                (.scrobbleWithLastFm, shouldScrobbleWithLastFm(), "Scrobble with Last.fm"),
                (.reverseSwipeDirection, isSwipeReverseEnabled(), "Reverse L/R Swipe Direction"),
                (.downloadArtwork, shouldDownloadArtwork(), "Download artwork"),
                (.artworkSize, preferredArtworkSizeEnum(), "Artwork size"),
                (.shakeToShuffle, shouldDetectShakeToShuffle(), "Shake to Shuffle"),
                (.equalizerActive, isEqualizerActive(), "Equalizer")
        ]
    }

    class func enabledStatusForSettingType(_ type: EPSettingType) -> Bool {
        switch type {
        case .scrobbleWithLastFm:
            return true

        default:
            return true
        }
    }

    @discardableResult class func changeSetting(_ type: EPSettingType, value: AnyObject?) -> AnyObject {

        switch type {

        case .shakeToShuffle:

            let specificValue: Bool!
            if value != nil {
                specificValue = value! as! Bool
            } else {
                specificValue = !shouldDetectShakeToShuffle()
            }

            UserDefaults.standard.set(specificValue, forKey: "ShakeToShuffle")
            shouldDetectShakeToShuffleValue = specificValue
            return (specificValue as AnyObject)

        case .scrobbleWithLastFm:

            let specificValue: Bool!
            if value != nil {
                specificValue = value! as! Bool
            } else {
                specificValue = !shouldScrobbleWithLastFm()
            }

            UserDefaults.standard.set(specificValue, forKey: "ScrobbleWithLastFm")
            shouldScrobbleWithLastFmValue = specificValue
            return (specificValue as AnyObject)

        case .reverseSwipeDirection:
            
            let specificValue: Bool!
            if value != nil {
                specificValue = value! as! Bool
            } else {
                specificValue = !isSwipeReverseEnabled()
            }
            
            UserDefaults.standard.set(specificValue, forKey: "SwipeReverseEnabled")
            isSwipeReverseEnabledValue = specificValue
            return (specificValue as AnyObject)
            
        case .downloadArtwork:

            let specificValue: Bool!
            if value != nil {
                specificValue = value! as! Bool
            } else {
                specificValue = !shouldDownloadArtwork()
            }

            UserDefaults.standard.set(specificValue, forKey: "DownloadArtwork")
            shouldDownloadArtworkValue = specificValue
            return (specificValue as AnyObject)

        case .equalizerActive:

            let specificValue: Bool!
            if value != nil {
                specificValue = value! as! Bool
            } else {
                specificValue = !isEqualizerActive()
            }
            EPMusicPlayer.sharedInstance.audioStreamSTK?.equalizerEnabled = specificValue
            UserDefaults.standard.set(specificValue, forKey: "EQActive")
            isEqualizerActiveValue = specificValue
            return (specificValue as AnyObject)

        case .artworkSize:

            let specificValue: EPArtworkSize!
            if value != nil {
                specificValue = value! as! EPArtworkSize
            } else {
                specificValue = nextArtworkSizeEnum(preferredArtworkSizeEnum())
            }

            let value = specificValue
            UserDefaults.standard.set(value?.rawValue, forKey: "ArtworkSize")
            preferredArtworkSizeEnumValue = value
            return preferredArtworkSizeString() as AnyObject
        }
    }
    
    static var shouldDetectShakeToShuffleValue: Bool?
    class func shouldDetectShakeToShuffle() -> (Bool) {
        //read from NSUserDefaults()
        if let value = shouldDetectShakeToShuffleValue {
            return value
        } else {

            if let value = UserDefaults.standard.object(forKey: "ShakeToShuffle") as? Bool {
                shouldDetectShakeToShuffleValue = value
                return shouldDetectShakeToShuffleValue!
            } else {
                UserDefaults.standard.set(true, forKey: "ShakeToShuffle")
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

            if let value = UserDefaults.standard.object(forKey: "ScrobbleWithLastFm") as? Bool {
                if lastfmMobileSession().characters.count == 0 {
                    UserDefaults.standard.set(false, forKey: "ScrobbleWithLastFm")
                    shouldScrobbleWithLastFmValue = false
                    return shouldScrobbleWithLastFmValue!
                } else {
                    shouldScrobbleWithLastFmValue = value
                    return shouldScrobbleWithLastFmValue!
                }

            } else {
                UserDefaults.standard.set(false, forKey: "ScrobbleWithLastFm")
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
            
            if let value = UserDefaults.standard.object(forKey: "SwipeReverseEnabled") as? Bool {
                isSwipeReverseEnabledValue = value
                return isSwipeReverseEnabledValue!
            } else {
                UserDefaults.standard.set(false, forKey: "SwipeReverseEnabled")
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

            if let value = UserDefaults.standard.object(forKey: "DownloadArtwork") as? Bool {
                shouldDownloadArtworkValue = value
                return shouldDownloadArtworkValue!
            } else {
                UserDefaults.standard.set(true, forKey: "DownloadArtwork")
                shouldDownloadArtworkValue = true
                return shouldDownloadArtworkValue!
            }
        }
    }

    static var preferredArtworkSizeEnumValue: EPArtworkSize?
    fileprivate class func preferredArtworkSizeEnum() -> EPArtworkSize {
        //read from NSUserDefaults()
        if let value = preferredArtworkSizeEnumValue {
            return value
        } else {

            if let value = UserDefaults.standard.object(forKey: "ArtworkSize") as? EPArtworkSize.RawValue {
                preferredArtworkSizeEnumValue = EPArtworkSize(rawValue: value)
                return preferredArtworkSizeEnumValue!
            } else {
                UserDefaults.standard.set(true, forKey: "ArtworkSize")
                preferredArtworkSizeEnumValue = EPArtworkSize.large
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

            if let value = UserDefaults.standard.object(forKey: "EQActive") as? Bool {
                isEqualizerActiveValue = value
                return isEqualizerActiveValue!
            } else {
                UserDefaults.standard.set(true, forKey: "EQActive")
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

            if let value = UserDefaults.standard.object(forKey: "LastfmSession") as? String {
                lastfmMobileSessionValue = value
                return lastfmMobileSessionValue!
            } else {
                UserDefaults.standard.set("", forKey: "LastfmSession")
                lastfmMobileSessionValue = ""
                return lastfmMobileSessionValue!
            }
        }
    }

    class func setLastfmSession(_ sessionString: String) {
        UserDefaults.standard.set(sessionString, forKey: "LastfmSession")
        lastfmMobileSessionValue = sessionString
    }

    class func nextArtworkSizeEnum(_ current: EPArtworkSize) -> EPArtworkSize {
        switch current {
        case .small:
            return .medium
        case .medium:
            return .large
        case .large:
            return .small
        }
    }

    //misc
    class func preferredArtworkSizeString() -> String {

        switch EPSettings.preferredArtworkSizeEnum() {
        case .small:
            return "200x200"

        case .medium:
            return "400x400"

        case .large:
            return "600x600"
        }
    }

    class func loadEQSettings() -> [Double] {
        if let EQGains = UserDefaults.standard.object(forKey: "EQGains") as? [Double] {
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

            UserDefaults.standard.set(EQGains, forKey: "EQGains")

            return EQGains
        }
    }
    
    class func isSettingAllowedDetails(_ setting:EPSettingType) -> Bool {
        switch setting {
            case .equalizerActive, .scrobbleWithLastFm:
                return true
            default:
                return false
        }
    }
}
