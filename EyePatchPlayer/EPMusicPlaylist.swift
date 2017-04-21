//
//  EPMusicPlaylist.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import Realm

enum PlaylistSource {
    case web
    case local
}

class EPMusicPlaylist: AnyObject {

    var tracks: [EPTrack] {
        get {
            return shuffleOn ? shuffledTracks : originalTracks
        }
    }

    weak var delegate: EPPlaylistDelegate?
    var source = PlaylistSource.web
    var identifier = "Unspecified"

    fileprivate var originalTracks: [EPTrack] = []

    lazy var shuffledTracks: [EPTrack] = {
        print("lazily loading shuffled playlist")
        
        var shuffledTracksLazy = self.originalTracks.shuffle()
        
        if shuffledTracksLazy.count == 0 {
            return []
        }
        
        var index: Int?
        for i in (0 ... shuffledTracksLazy.count - 1) {
            if shuffledTracksLazy[i].ID == EPMusicPlayer.sharedInstance.activeTrack.ID {
                index = i
                break
            }
        }
        
        if let index = index {
            let track = shuffledTracksLazy[0]
            shuffledTracksLazy[0] = shuffledTracksLazy[index]
            shuffledTracksLazy[index] = track
        }
        
        return shuffledTracksLazy
    }()
    
    var createdDate: Date!
    var trackCount: Int = 0
    var shuffleOn: Bool = false {
        didSet {
            //shuffle is the same as it was before
            if oldValue == shuffleOn {
                
            } else {
                //shuffle is different and is now on
                if shuffleOn {
                    self.reshuffle()
                }
            }
            print("playlistShuffle changed")
            self.delegate?.playlistDidChangeOrder()
        }
    }
    var responseJSON: NSDictionary?

    //MARK: Navigation

    func indexOfTrack(_ track: EPTrack) -> Int? {

        for iteratedTrack in self.tracks {
            if track.ID == iteratedTrack.ID {
                return self.tracks.index(of: iteratedTrack)
            }
        }

        return nil
    }

    //MARK: Playlist control interface

    func nextTrack() -> EPTrack? {
//        let startTime = CFAbsoluteTimeGetCurrent()
        print("nextTrack")
        
        if self.tracks.count == 0 {
            return nil
        }
        
        var index: Int?

        for i in (0 ... tracks.count - 1) {
            if tracks[i].ID == EPMusicPlayer.sharedInstance.activeTrack.ID {
                index = i
                break
            }
        }

        if let indexFound = index {
            if indexFound == tracks.count - 1 {
                if shuffleOn {
                    //last item, shuffle is on, playing first item from shuffled array
                    return tracks[0]
                } else {
                    //last item, cannot forward
                    print("index is max in a playlist, cannot get next track")
                    return nil
                }

            } else {
//                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
//                print("\(previousTrack):: Time: \(timeElapsed)")
                return tracks[indexFound + 1]
            }
        } else {
            print("index not found in a playlist")
        }

        return nil
    }

    func previousTrack() -> EPTrack? {
//        let startTime = CFAbsoluteTimeGetCurrent()

        print("previousTrack")
        
        if self.tracks.count == 0 {
            return nil
        }
        
        var index: Int?

        for i in (0 ... tracks.count - 1) {
            if tracks[i].ID == EPMusicPlayer.sharedInstance.activeTrack.ID {
                index = i
                break
            }
        }

        if let indexFound = index {
            if indexFound == 0 {

                if shuffleOn {
                    //last item, shuffle is on, playing last item from shuffled array
                    return tracks[tracks.count - 1]
                } else {
                    //last item, cannot backward
                    print("index is 0 in a playlist, cannot get previous track")
                    return nil
                }

            } else {
//                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
//                print("\(previousTrack):: Time: \(timeElapsed)")
                return tracks[indexFound - 1]
            }
        } else {
            print("index not found in a playlist")
        }

        return nil
    }

    func reshuffle() {
        self.shuffledTracks = self.originalTracks.shuffle()
        moveActiveTrackToZeroIndex()
        self.shuffleOn = true
    }

    func moveActiveTrackToZeroIndex() {
        
        if shuffledTracks.count == 0 || originalTracks.count == 0 {
            return
        }
        
        var index: Int?
        for i in (0 ... shuffledTracks.count - 1) {
            if shuffledTracks[i].ID == EPMusicPlayer.sharedInstance.activeTrack.ID {
                index = i
                break
            }
        }
        
        if let index = index {
            let track = shuffledTracks[0]
            shuffledTracks[0] = shuffledTracks[index]
            shuffledTracks[index] = track
        }
    }
    
    //MARK: Playlist Editing

    @discardableResult func removeTrack(_ track: EPTrack) -> Bool {

        var resultLinear = false
        var resultShuffled = false

        if self.originalTracks.count > 0 {
            for index in 0 ... self.originalTracks.count - 1 {
                if self.originalTracks[index].ID == track.ID {
                    self.originalTracks.remove(at: index)
                    resultLinear = true
                    break
                }
            }
        }

        if self.shuffledTracks.count > 0 {
            for index in 0 ... self.shuffledTracks.count - 1 {
                if self.shuffledTracks[index].ID == track.ID {
                    self.shuffledTracks.remove(at: index)
                    resultShuffled = true
                    break
                }
            }
        }

        if EPMusicPlayer.sharedInstance.activeTrack.ID == track.ID {
            if let _ = nextTrack() {
                EPMusicPlayer.sharedInstance.playNextSong()
            } else if let _ = previousTrack() {
                EPMusicPlayer.sharedInstance.playPrevSong()
            } else {
                print("cannot go next or prev, calling emergency track")
                //handle if no tracks left to switch to
                let emergencyTrack = EPTrack()

                if track.isInvalidated {
                    emergencyTrack.title = "No Track Selected"
                    emergencyTrack.artist = ""
                    emergencyTrack.duration = 0
                    emergencyTrack.URLString = ""
                } else {
                    emergencyTrack.title = track.title
                    emergencyTrack.artist = track.artist
                    emergencyTrack.artworkUIImage = track.artworkUIImage
                    emergencyTrack.duration = track.duration
                    emergencyTrack.URLString = ""
                }

                let playlist = EPMusicPlaylist(tracks: [emergencyTrack])
                EPMusicPlayer.sharedInstance.playTrackFromPlaylist(emergencyTrack, playlist: playlist)
            }
        }

        return resultLinear && resultShuffled
    }

    func addTrack(_ track: EPTrack, atEnd:Bool) {
        if atEnd {
            self.originalTracks.append(track)
            self.shuffledTracks = self.originalTracks.shuffle()
            self.trackCount = self.originalTracks.count
        } else {
            self.originalTracks.insert(track, at: 0)
            self.shuffledTracks = self.originalTracks.shuffle()
            self.trackCount = self.originalTracks.count
        }
    }
    
    func addTrack(_ track: EPTrack) {
        self.originalTracks.append(track)
        self.shuffledTracks = self.originalTracks.shuffle()
        self.trackCount = self.originalTracks.count
    }

    //MARK: Init methods
    init() {
        self.createdDate = Date()
        subscribeForPlaylistNotifications()
    }

    deinit {
        print("playlist: \(self.identifier) deinit")
        unsubscribeFromPlaylistNotifications()
    }

    init(tracks: [EPTrack]) {
        self.originalTracks = tracks
        self.trackCount = self.originalTracks.count
    }

    class func initWithResponseArray(_ response: NSArray) -> EPMusicPlaylist {
        let playlist: EPMusicPlaylist = EPMusicPlaylist()

        for trackJSON in response {
            let track: EPTrack = EPTrack.initWithResponse(trackJSON as! NSDictionary)
            playlist.originalTracks.append(track)
        }

        playlist.shuffledTracks = playlist.originalTracks.shuffle()
        
        print("track count total: \(playlist.trackCount)")
        print("track count loaded: \(playlist.originalTracks.count)")

        return playlist

    }

    class func initWithResponse(_ response: NSDictionary) -> EPMusicPlaylist {
        let playlist: EPMusicPlaylist = EPMusicPlaylist()

        playlist.responseJSON = response
        playlist.trackCount = (response["count"]! as AnyObject).intValue

        //        EPCache.cacheRetrievalExecutionTime = 0
        if let JSONArray: NSArray = response["items"] as? NSArray {
            for trackJSON in JSONArray {

                let track: EPTrack = EPTrack.initWithResponse(trackJSON as! NSDictionary)
                playlist.originalTracks.append(track)
            }
        } else {
            print("response[\"items\" is empty]")
        }

        playlist.shuffledTracks = playlist.originalTracks.shuffle()
        
        print("track count total: \(playlist.trackCount)")
        print("track count loaded: \(playlist.originalTracks.count)")

        return playlist
    }

    class func initWithRLMResults(_ results: RLMResults<RLMObject>) -> EPMusicPlaylist {
        let playlist: EPMusicPlaylist = EPMusicPlaylist()
        playlist.source = .local
        if (results.count > 0) {

            for i in 0..<results.count {
                if let track: EPTrack = results[i] as? EPTrack {
                    playlist.originalTracks.append(track)
                }
            }

            playlist.originalTracks = playlist.originalTracks.reversed()
        } else {
            print("results[\"items\" is empty]")
        }

        print("track count total: \(playlist.trackCount)")
        print("track count loaded: \(playlist.originalTracks.count)")

        return playlist
    }

    //MARK: Notifications

    func subscribeForPlaylistNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(EPMusicPlaylist.handleTrackDelete(_:)), name: NSNotification.Name(rawValue: "Track.Delete"), object: nil)
    }

    func unsubscribeFromPlaylistNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleTrackDelete(_ notification: Notification) {
        print("handleTrackDelete:\nplaylist: \(self.identifier) created @ \(self.createdDate)")
        if let userInfo = notification.userInfo as? [String:EPTrack], let track: EPTrack = userInfo["track"] {
            switch self.source {
            case .web:
                print("handleTrackDelete - web")
                for matchingTrack in self.originalTracks {
                    if matchingTrack.ID == track.ID {
                        matchingTrack.isCached = false
                    }
                }

                for matchingTrack in self.shuffledTracks {
                    if matchingTrack.ID == track.ID {
                        matchingTrack.isCached = false
                    }
                }
                break

            case .local:
                print("handleTrackDelete - local")
                self.removeTrack(track)

                break
            }
        }
    }
}
