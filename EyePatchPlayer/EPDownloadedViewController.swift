//
//  EPDownloadedViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPDownloadedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, EPPlaylistDelegate, EPTrackTableViewCellDelegate {
    
    @IBOutlet weak var playlistTableView: UITableView!
    
    var searchBar: UISearchBar!
    var playlist: EPMusicPlaylist = EPMusicPlaylist()
    var filteredSongs: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCell()
        
        self.filteredSongs = NSMutableArray()
        self.playlistTableView.alpha = 0
        self.searchBar = UISearchBar(frame:CGRectMake(0, 0, 320, 44));
        self.searchBar.delegate = self
        self.playlistTableView.tableHeaderView = searchBar;
        self.playlistTableView.tableFooterView = UIView(frame: CGRectMake(0,0,1,1))
        self.playlistTableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        drawRightMenuButton()
        subscribeForCacheNotifications()
        loadData()
    }

    func loadCell() {
        let nibName = UINib(nibName: "EPTrackTableViewCell", bundle:nil)
        self.playlistTableView.registerNib(nibName, forCellReuseIdentifier: "TrackCell")
    }
    
    func loadData() {
        let cachedTracks = EPTrack.allObjects()
        
        print("cachedTracks.count = \(cachedTracks.count)")
//        println("\(cachedTracks)")
        for trackRLM in cachedTracks {
            if let track: EPTrack = trackRLM as? EPTrack {
                print("track: \(track.ID) | \(track.artist) - \(track.title)")
            }
        }
        
        self.playlist = EPMusicPlaylist.initWithRLMResults(cachedTracks)
        self.playlist.delegate = self
        
        self.playlistTableView.dataSource = self
        self.playlistTableView.delegate = self
        self.playlistTableView.reloadData()

        self.highlightActiveTrack()

        self.applyOffset()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.playlistTableView.alpha = 1
        })
    }
    
    func highlightActiveTrack() {
        if EPMusicPlayer.sharedInstance.isPlaying() == true {
            if hasFilterActive() {
                for trackObject in self.filteredSongs {
                    if let track:EPTrack = trackObject as? EPTrack {
                        if track.ID == EPMusicPlayer.sharedInstance.activeTrack.ID {
                            let index = self.filteredSongs.indexOfObject(trackObject)
                            self.playlistTableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
                        }
                    }
                }
            } else {
                for track in self.playlist.tracks {
                    if track.ID == EPMusicPlayer.sharedInstance.activeTrack.ID {
                        if let index = self.playlist.tracks.indexOf(track) {
                            self.playlistTableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Middle)
                        }
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
            print(self.filteredSongs.count)
            if (self.filteredSongs.count > 0){
                track = self.filteredSongs[indexPath.row] as! EPTrack
                if EPMusicPlayer.sharedInstance.activeTrack.ID == track.ID {
                    EPMusicPlayer.sharedInstance.playNextSong()
                }
                self.playlist.removeTrack(track)
                filterSongsInArray()
                print(self.filteredSongs.count)
            } else {
                
                track = self.playlist.tracks[indexPath.row]
                if EPMusicPlayer.sharedInstance.activeTrack.ID == track.ID {
                    EPMusicPlayer.sharedInstance.playNextSong()
                }
                self.playlist.tracks.removeAtIndex(indexPath.row)
                
            }
            
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
        if (searchText.characters.count>0){
            
            filterSongsInArray()
            self.playlistTableView.reloadData()
            highlightActiveTrack()

        } else {
            self.filteredSongs = NSArray()
            self.playlistTableView.reloadData()
            highlightActiveTrack()

        }
    }
    
    func filterSongsInArray(){
        let predicate = NSPredicate(format: "artist contains[c] %@ OR title contains[c] %@", self.searchBar.text!, self.searchBar.text!) // if you need case sensitive search avoid '[c]' in the predicate
        let arrayCast =  self.playlist.tracks as NSArray
        self.filteredSongs = arrayCast.filteredArrayUsingPredicate(predicate) as NSArray
    }
    
    func applyOffset(){
        var contentOffset = self.playlistTableView.contentOffset
        contentOffset.y += CGRectGetHeight(self.searchBar!.frame)
        self.playlistTableView.contentOffset = contentOffset
    }
    
    //tableview
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: EPTrackTableViewCell? = self.playlistTableView.dequeueReusableCellWithIdentifier("TrackCell") as? EPTrackTableViewCell
        
        if cell == nil {
            cell = EPTrackTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TrackCell")
        }
        let track: EPTrack
        if (self.filteredSongs.count > 0){
            track = self.filteredSongs[indexPath.row] as! EPTrack
        } else {
            track = self.playlist.tracks[indexPath.row]
        }
        
        cell?.delegate = self
        
        cell!.setCacheStatus(track.isCached)
        cell!.titleLabel?.text = track.title
        cell!.artistLabel?.text = track.artist
        cell?.durationLabel.text = track.duration.timeInSecondsToString()
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let text =  searchBar.text else {
            return 0
        }
        return text.characters.count > 0 ? self.filteredSongs.count : self.playlist.tracks.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedTrack: EPTrack!
        guard let text = searchBar.text else {
            return
        }
        if (text.characters.count > 0){
            selectedTrack = self.filteredSongs[indexPath.row] as! EPTrack
        } else {
            selectedTrack = self.playlist.tracks[indexPath.row]
        }
        
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
            if self.hasFilterActive() {
                selectedTrack = self.filteredSongs[indexPath.row] as! EPTrack
            } else {
                selectedTrack = self.playlist.tracks[indexPath.row]
            }
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
        if self.hasFilterActive() {
            index = self.filteredSongs.indexOfObject(track)
        } else {
            index = self.playlist.tracks.indexOf(track)
        }
        
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
    
    // misc
    
    func hasFilterActive() -> Bool {
        
        guard let text = searchBar.text else {
            return false
        }
        
        return (text.characters.count > 0)
    }
    
}
