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
        
        if let LastFMAPIKey = Bundle.main.object(forInfoDictionaryKey: "LastFMAPIKey") as? String {
            LastFM.APIKey = LastFMAPIKey
        }
        
        if let LastFMSecret = Bundle.main.object(forInfoDictionaryKey: "LastFMSecret") as? String {
            LastFM.Secret = LastFMSecret
        }
    }

    struct LastFM {
        static var APIKey = ""
        static var Secret = ""
        static var APIRootURL = "https://ws.audioscrobbler.com/2.0/"
    }

}
