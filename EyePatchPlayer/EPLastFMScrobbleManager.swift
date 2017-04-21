//
//  EPLastFMScrobbleManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 25/11/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import AFNetworking
import Realm

class EPLastFMScrobbleManager: NSObject {

    static let playbackPercentCompleteToScrobble = 0.25
    static var queueIsEmpty = false

    class func enqueueTrackForScrobbling(_ track: EPTrack) {
        //create Scrobble Instance for backup if on-the-spot scrobbling fails
        let scrobble = EPLastFMScrobble.initWithTrack(track)
        if AFNetworkReachabilityManager.shared().isReachable {
            //attempt to scrobble now
            EPHTTPLastFMManager.scrobbleTrack(scrobble, completion: {
                (result) -> Void in
                if result {

                } else {
                    //store in database for postponed scrobbling
                    postponeScrobble(scrobble)
                }
            })
        } else {
            //store in database for postponed scrobbling
            postponeScrobble(scrobble)
        }
    }

    class func scrobbleFullQueue() {

        if (queueIsEmpty) {
            return
        }

        let results = EPLastFMScrobble.allObjects()
        if results.count > 0 {
            var scrobbleQueueArray = [EPLastFMScrobble]()

            for i in 0..<results.count {
                if let scrobble = results[i] as? EPLastFMScrobble {
                    scrobbleQueueArray.append(scrobble)
                }
            }

            scrobbleQueue(scrobbleQueueArray)
        } else {
            print("scrobble queue is empty")
            queueIsEmpty = true
        }

    }

    fileprivate class func postponeScrobble(_ scrobble: EPLastFMScrobble) {
        print("postpone scrobble: \(scrobble.artist) - \(scrobble.track)")
        queueIsEmpty = false

        do {
            RLMRealm.default().beginWriteTransaction()
            RLMRealm.default().add(scrobble)
            try RLMRealm.default().commitWriteTransaction()
        } catch {

        }

    }

    private class func scrobbleQueue(_ scrobbleQueueArray: [EPLastFMScrobble]) {
        var scrobbleQueueArray = scrobbleQueueArray
        print("scrobbleQueue called")
        if (scrobbleQueueArray.count > 0) {
            print("scrobbleQueue: \(scrobbleQueueArray.count) items")
            if let scrobble = scrobbleQueueArray.first {
                EPHTTPLastFMManager.scrobbleTrack(scrobble, completion: {
                    (result) -> Void in
                    if result {
                        scrobbleQueueArray.removeFirst()
                        if !scrobble.isInvalidated {

                            do {
                                RLMRealm.default().beginWriteTransaction()
                                RLMRealm.default().delete(scrobble)
                                try RLMRealm.default().commitWriteTransaction()
                            } catch {
                                
                            }

                        }
                        self.scrobbleQueue(scrobbleQueueArray)
                    } else {
                        print("stopping scrobbling queue, error occured")
                        //store in database for postponed scrobbling
                    }
                })
            }

        } else {
            print("scrobbleQueue: empty")
            queueIsEmpty = true
        }
    }
}
