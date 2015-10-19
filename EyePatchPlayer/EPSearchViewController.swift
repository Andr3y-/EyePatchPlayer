//
//  SecondViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, EPPlaylistDelegate, EPTrackTableViewCellDelegate {

    @IBOutlet weak var playlistTableView: UITableView!
    
    var searchBar: UISearchBar!
    var playlist: EPMusicPlaylist = EPMusicPlaylist()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCell()
        
        self.playlistTableView.alpha = 1
        self.searchBar = UISearchBar(frame:CGRectMake(0, 0, 320, 44));
        self.searchBar.delegate = self
        self.playlistTableView.tableHeaderView = searchBar;
        self.playlistTableView.tableFooterView = UIView(frame: CGRectMake(0,0,1,1))
        self.playlistTableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        drawRightMenuButton()
        subscribeForCacheNotifications()
    }
    
    func loadCell() {
        let nibName = UINib(nibName: "EPTrackTableViewCell", bundle:nil)
        self.playlistTableView.registerNib(nibName, forCellReuseIdentifier: "TrackCell")
    }
    
    func loadData() {
        let audioRequest: VKRequest = VKRequest(method: "audio.search", andParameters: [VK_API_Q : self.searchBar.text!, VK_API_COUNT : 100], andHttpMethod: "GET")
        audioRequest.executeWithResultBlock({ (response) -> Void in
            
            self.playlist = EPMusicPlaylist.initWithResponse(response.json as! NSDictionary)
            self.playlistTableView.dataSource = self
            self.playlistTableView.delegate = self
            self.playlistTableView.reloadData()
            
            self.highlightActiveTrack()
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.playlistTableView.alpha = 1
            })
            print("loadedTracks.count = \(self.playlist.tracks.count)")

            }, errorBlock: { (error) -> Void in
                
        })
        
    }
    
    func highlightActiveTrack() {
        if EPMusicPlayer.sharedInstance.isPlaying() == true {
            for track in self.playlist.tracks {
                if track.ID == EPMusicPlayer.sharedInstance.activeTrack.ID {
                    if let index = self.playlist.tracks.indexOf(track) {
                        self.playlistTableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Middle)
                    }
                }
            }
        }
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
            self.playlist.tracks.append(track)
            self.playlistTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let track: EPTrack
            
            track = self.playlist.tracks[indexPath.row]
            if EPMusicPlayer.sharedInstance.activeTrack.ID == track.ID {
                EPMusicPlayer.sharedInstance.playNextSong()
            }
            self.playlist.tracks.removeAtIndex(indexPath.row)
                
            
            if EPCache.deleteTrackFromDownload(track) {
                self.playlistTableView.deleteRowsAtIndexPaths(NSArray(object: indexPath) as! [NSIndexPath], withRowAnimation: UITableViewRowAnimation.Left)
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            if searchText == self.searchBar.text{
//                self.loadData()
//            }
//            
//        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchText = searchBar.text where searchText.characters.count > 0 {
            self.loadData()
        }
    }
    
    
    //tableview
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: EPTrackTableViewCell? = self.playlistTableView.dequeueReusableCellWithIdentifier("TrackCell") as? EPTrackTableViewCell
        
        if cell == nil {
            cell = EPTrackTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "TrackCell")
        }
        let track: EPTrack
        track = self.playlist.tracks[indexPath.row]
        
        cell?.delegate = self
        
        cell!.setCacheStatus(track.isCached)
        cell!.titleLabel?.text = track.title
        cell!.artistLabel?.text = track.artist
        cell?.durationLabel.text = track.duration.timeInSecondsToString()
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlist.tracks.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedTrack: EPTrack!
        
        selectedTrack = self.playlist.tracks[indexPath.row]
        
        EPMusicPlayer.sharedInstance.playTrackFromPlaylist(selectedTrack, playlist: self.playlist)
    }
    

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    //cells delegating
    
    func cellDetectedPrimaryTap(cell: EPTrackTableViewCell) {
        let selectedTrack: EPTrack!
        
        //        cell.setSelected(true, animated: true)
        if let indexPathsForSelectedRow = self.playlistTableView.indexPathForSelectedRow {
            print("hasIndexPathForSelectedRow = 1")
            self.playlistTableView.deselectRowAtIndexPath(indexPathsForSelectedRow, animated: true)
        } else {
            print("hasIndexPathForSelectedRow = 0")
        }
        self.playlistTableView.selectRowAtIndexPath(self.playlistTableView.indexPathForCell(cell), animated: true, scrollPosition: UITableViewScrollPosition.None)
        if let indexPath = self.playlistTableView.indexPathForCell(cell) {
            selectedTrack = self.playlist.tracks[indexPath.row]
            EPMusicPlayer.sharedInstance.playTrackFromPlaylist(selectedTrack, playlist: self.playlist)
        }
    }
    
    func cellDetectedSecondaryTap(cell: EPTrackTableViewCell) {
        
    }
    
    //Playlist Delegate
    
    //EPPlaylistDelegate
    func playlistDidSetTrackActive(track:EPTrack) {
        print("playlistDidSetTrackActive")
        let index:Int?
        index = self.playlist.tracks.indexOf(track)
        
        if let indexPathsForSelectedRow = self.playlistTableView.indexPathForSelectedRow {
            print("hasIndexPathForSelectedRow = 1")
            self.playlistTableView.deselectRowAtIndexPath(indexPathsForSelectedRow, animated: true)
        } else {
            print("hasIndexPathForSelectedRow = 0")
        }
        
        if let index = index {
            self.playlistTableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
        }
    }

}

