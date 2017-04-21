//
//  EPConstants.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import Foundation

struct EPConstants{
    
    static func loadPlistValues() {
        
        if let VKAppID = Bundle.main.object(forInfoDictionaryKey: "VKAppID") as? String {
            VK.AppID = VKAppID
        }
        
        if let ParseKey = Bundle.main.object(forInfoDictionaryKey: "ParseKey") as? String {
            Parse.Key = ParseKey
        }
        
        if let ParseAppID = Bundle.main.object(forInfoDictionaryKey: "ParseAppID") as? String {
            Parse.AppID = ParseAppID
        }
        
        if let LastFMAPIKey = Bundle.main.object(forInfoDictionaryKey: "LastFMAPIKey") as? String {
            LastFM.APIKey = LastFMAPIKey
        }
        
        if let LastFMSecret = Bundle.main.object(forInfoDictionaryKey: "LastFMSecret") as? String {
            LastFM.Secret = LastFMSecret
        }
    }
    
    struct VK {
        static var AppID = ""
    }
    
    struct Parse {
        static var Key = ""
        static var AppID = ""
    }
    

    struct LastFM {
        static var APIKey = ""
        static var Secret = ""
        static var APIRootURL = "https://ws.audioscrobbler.com/2.0/"
    }

}
