//
//  EPTrackDelegate.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 12/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

protocol EPPlaylistDelegate {
    func playlistDidSetTrackActive(track:EPTrack)
    func playlistDidChangeOrder()
}
