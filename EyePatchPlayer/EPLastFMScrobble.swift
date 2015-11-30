//
//  EPLastFMScrobble.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 25/11/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPLastFMScrobble: RLMObject {

    dynamic var timestamp: Int = 0
    dynamic var artist: String = ""
    dynamic var track: String = ""
    dynamic var duration: Int = 0

    override init() {
        super.init()
    }

    class func initWithTrack(track: EPTrack) -> EPLastFMScrobble {
        let scrobble = EPLastFMScrobble()

        scrobble.timestamp = Int(NSDate().timeIntervalSince1970 - EPLastFMScrobbleManager.playbackPercentCompleteToScrobble * Double(track.duration))


        if let startRange = track.title.rangeOfString("["), let endRange = track.title.rangeOfString("]") {
            scrobble.track = track.title.stringByReplacingCharactersInRange(Range<String.Index>(start: startRange.startIndex, end: endRange.endIndex), withString: "")
        } else {
            scrobble.track = track.title
        }

        scrobble.artist = track.artist
        scrobble.duration = track.duration

        return scrobble
    }

    init(track: EPTrack) {

        self.timestamp = Int(NSDate().timeIntervalSince1970 - EPLastFMScrobbleManager.playbackPercentCompleteToScrobble * Double(track.duration))
//        let trackTitle:String!

        if let startRange = track.title.rangeOfString("["), let endRange = track.title.rangeOfString("]") {
            self.track = track.title.stringByReplacingCharactersInRange(Range<String.Index>(start: startRange.startIndex, end: endRange.endIndex), withString: "")
        } else {
            self.track = track.title
        }

        self.artist = track.artist//.stringByReplacingOccurrencesOfString("&", withString: "&amp;")
//        if let clearedTrackTitle = trackTitle.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
//            self.track = clearedTrackTitle
//        } else {
//            self.track = trackTitle
//        }

//        if let clearedTrackArtist = track.artist.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
//            self.artist = clearedTrackArtist
//        } else {
//            self.artist = track.artist
//        }

        self.duration = track.duration

        super.init()
    }

}
