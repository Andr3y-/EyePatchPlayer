//
//  EPHTTPLastFMManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 11/02/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import AFNetworking
import CryptoSwift

class EPHTTPLastFMManager: NSObject {
    
    private static var lastfmManager:AFHTTPRequestOperationManager = {
        var manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.operationQueue.maxConcurrentOperationCount = 3
        return manager
    }()

    class func broadcastTrack(track: EPTrack, completion: ((result:Bool) -> Void)?) {
        if EPSettings.lastfmMobileSession().characters.count < 1 || !AFNetworkReachabilityManager.sharedManager().reachable {
            return
        }
        
        let scrobble = EPLastFMScrobble(track: track)
        let parameters =
        [
            "method": "track.updateNowPlaying",
            "artist": scrobble.artist,
            "track": scrobble.track,
            "api_key": EPConstants.LastFM.APIKey,
            "duration": String(scrobble.duration),
            "sk": EPSettings.lastfmMobileSession()
        ]
        
        guard let URL = self.URLStringForMethod(parameters) else {
            if completion != nil {
                completion!(result: false)
            }
            return
        }
        
        lastfmManager.POST(URL, parameters: nil, success: {
            (operation, response) -> Void in
            print("lastfm track.updateNowPlaying success")
            if completion != nil {
                completion!(result: true)
            }
            }) {
                (operation, error) -> Void in
                print("lastfm track.updateNowPlaying failure")
                
                if let operation = operation {
                    print(operation.response)
                }
                
                if completion != nil {
                    completion!(result: false)
                }
        }
    }
    
    class func scrobbleTrack(scrobble: EPLastFMScrobble, completion: ((result:Bool) -> Void)?) {
        if scrobble.invalidated {
            return
        }
        
        let parameters =
        [
            "method": "track.scrobble",
            "artist": scrobble.artist,
            "track": scrobble.track,
            "api_key": EPConstants.LastFM.APIKey,
            "timestamp": String(scrobble.timestamp),
            "duration": String(scrobble.duration),
            "sk": EPSettings.lastfmMobileSession()
        ]
        
        guard let URL = self.URLStringForMethod(parameters) else {
            if completion != nil {
                completion!(result: false)
            }
            return
        }
        
        lastfmManager.POST(URL, parameters: nil, success: {
            (operation, response) -> Void in
            print("lastfm scrobbling success")
            if completion != nil {
                completion!(result: true)
            }
            }) {
                (operation, error: NSError) -> Void in
                if let data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? NSData {
                    if let errorResponse = String(data: data, encoding: NSUTF8StringEncoding) {
                        print("lastfm scrobbling failure:\ncode:\(error.code)\nresponse:\(errorResponse)")
                        if completion != nil {
                            completion!(result: false)
                        }
                        return
                    }
                }
                print("lastfm scrobbling failure:\ncode:\(error.code)\nresponse: no data")
                if completion != nil {
                    completion!(result: false)
                }
                return
        }
    }
    
    class func authenticate(username: String, password: String, completion: ((result:Bool, session:String) -> Void)?) {
        print("lastfmAuthenticate initiated")
        let parameters =
        [
            "method": "auth.getMobileSession",
            "username": username,
            "password": password,
            "api_key": EPConstants.LastFM.APIKey
            
        ]
        
        guard let URL = self.URLStringForMethod(parameters) else {
            if completion != nil {
                completion!(result: false, session: "")
            }
            return
        }
        lastfmManager.POST(URL, parameters: nil, success: {
            (operation, response) -> Void in
            print("lastfm auth success: \(response)")
            if let sessionObject: AnyObject = response["session"] {
                if let sessionDictionary = sessionObject as? [String:AnyObject] {
                    if let sessionKey = sessionDictionary["key"] as? String {
                        if completion != nil {
                            completion!(result: true, session: sessionKey)
                        }
                    }
                }
            }
            
            }) {
                (operation, error: NSError) -> Void in
                print("lastfm auth failure:\ncode:\(error.code)")
                if completion != nil {
                    completion!(result: false, session: "")
                }
        }
    }
    
    private class func URLStringForMethod(parameters: [String:String]) -> String? {
        var URL = "\(EPConstants.LastFM.APIRootURL)?"
        for (key, value) in parameters {
            
            URL.appendContentsOf(key)
            URL.appendContentsOf("=")
            if let clearedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) {
                URL.appendContentsOf(clearedValue.stringByReplacingOccurrencesOfString("&", withString: "%26"))
            } else {
                return nil
            }
            URL.appendContentsOf("&")
        }
        guard let api_sig = self.methodSignature(parameters) else {
            return nil
        }
        URL.appendContentsOf("api_sig=")
        URL.appendContentsOf(api_sig)
        URL.appendContentsOf("&format=json")
        //        print("URL to sign: \(URL)")
        return URL
    }
    
    private class func methodSignature(parameters: [String:String]) -> String? {
        //sort abc...xyz
        let parametersSorted = parameters.keys.sort()
        var rawSignature = ""
        //construct rawSignature step 1
        for key in parametersSorted {
            rawSignature.appendContentsOf(key)
            guard let appendingValue = parameters[key] else {
                return nil
            }
            rawSignature.appendContentsOf(appendingValue)
        }
        //construct rawSignature step 2
        rawSignature.appendContentsOf(EPConstants.LastFM.Secret)
        //construction complete, return md5
        //        print("signature: \(rawSignature)")
        //        print("md5 sign:  \(rawSignature.md5())")
        return rawSignature.md5()
    }
}
