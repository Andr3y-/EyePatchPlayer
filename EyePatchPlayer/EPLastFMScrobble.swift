//
//  EPLastFMScrobble.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 25/11/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import Realm

class EPLastFMScrobble: RLMObject {

    dynamic var timestamp: Int = 0
    dynamic var artist: String = ""
    dynamic var track: String = ""
    dynamic var duration: Int = 0

    override init() {
        super.init()
    }

    class func initWithTrack(_ track: EPTrack) -> EPLastFMScrobble {
        let scrobble = EPLastFMScrobble()

        scrobble.timestamp = Int(Date().timeIntervalSince1970 - EPLastFMScrobbleManager.playbackPercentCompleteToScrobble * Double(track.duration))


        if let startRange = track.title.range(of: "["), let endRange = track.title.range(of: "]") {

            scrobble.track = track.title.replacingCharacters(in: (startRange.lowerBound..<endRange.upperBound), with: "")
            
        } else {
            scrobble.track = track.title
        }

        scrobble.artist = track.artist
        scrobble.duration = track.duration

        return scrobble
    }

    init(track: EPTrack) {

        self.timestamp = Int(Date().timeIntervalSince1970 - EPLastFMScrobbleManager.playbackPercentCompleteToScrobble * Double(track.duration))

        if let startRange = track.title.range(of: "["), let endRange = track.title.range(of: "]") {
            self.track = track.title.replacingCharacters(in: (startRange.lowerBound..<endRange.upperBound), with: "")
        } else {
            self.track = track.title
        }

        self.artist = track.artist//.stringByReplacingOccurrencesOfString("&", withString: "&amp;")


        self.duration = track.duration

        super.init()
    }

}
