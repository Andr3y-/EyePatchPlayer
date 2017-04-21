//
//  EPTrackDelegate.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 12/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

protocol EPPlaylistDelegate: class {
    func playlistDidSetTrackActive(_ track: EPTrack)

    func playlistDidChangeOrder()
}
