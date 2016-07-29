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
        NSNotificationCenter.defaultCenter().addObserver(
        self,
                selector: "handleTrackCached:",
                name: "TrackCached",
                object: nil)
    }

    func handleTrackCached(notification: NSNotification) {
        print("handleTrackCached")
        if let track: EPTrack = notification.object as? EPTrack {
            self.playlist.addTrack(track, atEnd: false)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {

            let track: EPTrack

            if hasFilterActive() {
                track = self.filteredPlaylist.tracks[indexPath.row]
//                if EPMusicPlayer.sharedInstance.activeTrack.ID == track.ID {
//                    EPMusicPlayer.sharedInstance.playNextSong()
//                }
                self.playlist.removeTrack(track)
                filterSongsInArray()
            } else {
                track = self.playlist.tracks[indexPath.row]
//                if EPMusicPlayer.sharedInstance.activeTrack.ID == track.ID {
//                    EPMusicPlayer.sharedInstance.playNextSong()
//                }
                self.playlist.removeTrack(track)
            }

            if EPCache.deleteTrackFromDownload(track) {
                self.tableView.deleteRowsAtIndexPaths(NSArray(object: indexPath) as! [NSIndexPath], withRowAnimation: UITableViewRowAnimation.Left)
            }

            highlightActiveTrack(false, animated: false)
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        if let selectedIndexPaths = self.tableView.indexPathsForSelectedRows {
            
            super.setEditing(editing, animated: animated)

            for indexPath in selectedIndexPaths {
                self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            }
        } else {
            super.setEditing(editing, animated: animated)
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func cellDetectedSecondaryTap(cell: EPTrackTableViewCell) {
        //handle delete
    }

    deinit {
        self.tableView.editing = false
    }

}
