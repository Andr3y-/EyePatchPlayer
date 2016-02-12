//
//  EPLastFMScrobbleManager.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 25/11/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import AFNetworking

class EPLastFMScrobbleManager: NSObject {

    static let playbackPercentCompleteToScrobble = 0.25
    static var queueIsEmpty = false

    class func enqueueTrackForScrobbling(track: EPTrack) {
        //create Scrobble Instance for backup if on-the-spot scrobbling fails
        let scrobble = EPLastFMScrobble.initWithTrack(track)
        if AFNetworkReachabilityManager.sharedManager().reachable {
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

            for scrobbleItem in results {
                if let scrobble = scrobbleItem as? EPLastFMScrobble {
                    scrobbleQueueArray.append(scrobble)
                }
            }

            scrobbleQueue(scrobbleQueueArray)
        } else {
            print("scrobble queue is empty")
            queueIsEmpty = true
        }

    }

    private class func postponeScrobble(scrobble: EPLastFMScrobble) {
        print("postpone scrobble: \(scrobble.artist) - \(scrobble.track)")
        queueIsEmpty = false
        RLMRealm.defaultRealm().beginWriteTransaction()
        RLMRealm.defaultRealm().addObject(scrobble)
        RLMRealm.defaultRealm().commitWriteTransaction()

    }

    private class func scrobbleQueue(var scrobbleQueueArray: [EPLastFMScrobble]) {
        print("scrobbleQueue called")
        if (scrobbleQueueArray.count > 0) {
            print("scrobbleQueue: \(scrobbleQueueArray.count) items")
            if let scrobble = scrobbleQueueArray.first {
                EPHTTPLastFMManager.scrobbleTrack(scrobble, completion: {
                    (result) -> Void in
                    if result {
                        scrobbleQueueArray.removeFirst()
                        if !scrobble.invalidated {
                            RLMRealm.defaultRealm().beginWriteTransaction()
                            RLMRealm.defaultRealm().deleteObject(scrobble)
                            RLMRealm.defaultRealm().commitWriteTransaction()
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
