//
//  EPMusicPlayerDelegate.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 01/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

protocol EPMusicPlayerDelegate: class {
    func playbackProgressUpdate(currentTime: Int, bufferedPercent: Double)

    func playbackStatusUpdate(playbackStatus: PlaybackStatus)

    func playbackTrackUpdate()

    func trackCachedWithResult(result: Bool)

    func trackRetrievedArtworkImage(image: UIImage)
}
