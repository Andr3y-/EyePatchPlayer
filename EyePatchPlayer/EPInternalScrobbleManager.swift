//
//  EPInternalScrobbleManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 25/01/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import UIKit
import Parse

class EPInternalScrobbleManager: NSObject {
    
    class func enqueueTrackForScrobbling(_ track: EPTrack) {
        let scrobble = PFObject(className: "Scrobble")

        scrobble["artist"] = track.artist
        scrobble["title"] = track.title
        scrobble["VKUserID"] = EPUserData.VKID()
        scrobble["time"] = Date()
        scrobble.saveInBackground { (succeeded: Bool, error:Error?) -> Void in
            if (succeeded) {
                print("parse: scrobble succeeded")
            } else {
                print("parse: scrobble failed")
                scrobble.saveEventually()
            }
        }
    }
}
