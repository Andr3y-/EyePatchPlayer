//
//  EPHTTPLastFMManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 11/02/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import Alamofire

class EPHTTPLastFMManager: NSObject {

    class func broadcastTrack(_ track: EPTrack, completion: ((_ result:Bool) -> Void)?) {
        if EPSettings.lastfmMobileSession().characters.count < 1 {
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
                completion!(false)
            }
            return
        }

        Alamofire.request(URL, method: .post).validate().responseJSON { (response) in

            guard let _ = response.result.value as? [String: AnyObject] else {

                print("lastfm track.updateNowPlaying failure")
                completion?(false)
                return
            }

            completion?(true)
        }
    }
    
    class func scrobbleTrack(_ scrobble: EPLastFMScrobble, completion: ((_ result:Bool) -> Void)?) {
        if scrobble.isInvalidated {
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
                completion!(false)
            }
            return
        }

        Alamofire.request(URL, method: .post).validate().responseJSON { (response) in

            guard let _ = response.result.value as? [String: AnyObject] else {

                print("lastfm scrobbling failure")
                completion?(false)
                return
            }

            completion?(true)
        }

    }
    
    class func authenticate(_ username: String, password: String, completion: ((_ result:Bool, _ session:String) -> Void)?) {
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
                completion!(false, "")
            }
            return
        }


        Alamofire.request(URL, method: .post).validate().responseJSON { (response) in

            guard let response = response.result.value as? [String: AnyObject] else {

                print("lastfm auth failure")
                completion?(false, "")
                return
            }

            print("lastfm auth success: \(response)")
            if let sessionDictionary = response["session"] as? [String: AnyObject] {
                if let sessionKey = sessionDictionary["key"] as? String {
                        completion?(true, sessionKey)
                }
            }
        }


    }
    
    fileprivate class func URLStringForMethod(_ parameters: [String:String]) -> String? {
        var URL = "\(EPConstants.LastFM.APIRootURL)?"
        for (key, value) in parameters {
            
            URL.append(key)
            URL.append("=")
            if let clearedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                URL.append(clearedValue.replacingOccurrences(of: "&", with: "%26"))
            } else {
                return nil
            }
            URL.append("&")
        }
        guard let api_sig = self.methodSignature(parameters) else {
            return nil
        }
        URL.append("api_sig=")
        URL.append(api_sig)
        URL.append("&format=json")
        //        print("URL to sign: \(URL)")
        return URL
    }
    
    fileprivate class func methodSignature(_ parameters: [String:String]) -> String? {
        //sort abc...xyz
        let parametersSorted = parameters.keys.sorted()
        var rawSignature = ""
        //construct rawSignature step 1
        for key in parametersSorted {
            rawSignature.append(key)
            guard let appendingValue = parameters[key] else {
                return nil
            }
            rawSignature.append(appendingValue)
        }
        //construct rawSignature step 2
        rawSignature.append(EPConstants.LastFM.Secret)
        //construction complete, return md5
        //        print("signature: \(rawSignature)")
        //        print("md5 sign:  \(rawSignature.md5())")
        return rawSignature//.md5()
    }
}
