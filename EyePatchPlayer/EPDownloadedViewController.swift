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
    }

    override func loadData() {
        let cachedTracks = EPTrack.allObjects()
        self.playlist = EPMusicPlaylist.initWithRLMResults(cachedTracks)
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
            self.playlist.addTrack(track)
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let track: EPTrack
            print(self.filteredPlaylist.tracks.count)
            if (self.filteredPlaylist.tracks.count > 0){
                track = self.filteredPlaylist.tracks[indexPath.row]
                if EPMusicPlayer.sharedInstance.activeTrack.ID == track.ID {
                    EPMusicPlayer.sharedInstance.playNextSong()
                }
                self.playlist.removeTrack(track)
                filterSongsInArray()
                print(self.filteredPlaylist.tracks.count)
            } else {
                
                track = self.playlist.tracks[indexPath.row]
                if EPMusicPlayer.sharedInstance.activeTrack.ID == track.ID {
                    EPMusicPlayer.sharedInstance.playNextSong()
                }
                self.playlist.removeTrack(track)
                
            }
            
            if EPCache.deleteTrackFromDownload(track) {
                self.tableView.deleteRowsAtIndexPaths(NSArray(object: indexPath) as! [NSIndexPath], withRowAnimation: UITableViewRowAnimation.Left)
            }
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func cellDetectedSecondaryTap(cell: EPTrackTableViewCell) {
        //handle delete
    }

}
