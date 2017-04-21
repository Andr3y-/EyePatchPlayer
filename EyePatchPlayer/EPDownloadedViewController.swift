//
//  EPDownloadedViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPDownloadedViewController: EPPlaylistAbstractViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeForCacheNotifications()
        self.tableView.allowsSelectionDuringEditing = true
    }

    override func loadData() {
        let cachedTracks = EPTrack.allObjects()
        
        self.playlist = EPMusicPlaylist.initWithRLMResults(cachedTracks)
        self.playlist.identifier = "Library"
        
        dataReady()
    }
    
    func subscribeForCacheNotifications() {
        NotificationCenter.default.addObserver(
        self,
                selector: #selector(EPDownloadedViewController.handleTrackCached(_:)),
                name: NSNotification.Name(rawValue: "TrackCached"),
                object: nil)
    }

    func handleTrackCached(_ notification: Notification) {
        print("handleTrackCached")
        if let track: EPTrack = notification.object as? EPTrack {
            self.playlist.addTrack(track, atEnd: false)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.right)
        }
    }

    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {

            let track: EPTrack

            if hasFilterActive() {
                track = self.filteredPlaylist.tracks[indexPath.row]
                self.playlist.removeTrack(track)
                filterSongsInArray()
            } else {
                track = self.playlist.tracks[indexPath.row]
                self.playlist.removeTrack(track)
            }

            if EPCache.deleteTrackFromDownload(track) {
                self.tableView.deleteRows(at: NSArray(object: indexPath) as! [IndexPath], with: UITableViewRowAnimation.left)
            }

            highlightActiveTrack(false, animated: false)
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        if let selectedIndexPaths = self.tableView.indexPathsForSelectedRows {
            
            super.setEditing(editing, animated: animated)

            for indexPath in selectedIndexPaths {
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        } else {
            super.setEditing(editing, animated: animated)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func cellDetectedSecondaryTap(_ cell: EPTrackTableViewCell) {
        //handle delete
    }

    deinit {
        self.tableView.isEditing = false
    }

}
