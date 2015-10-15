//
//  EPDownloadedViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPDownloadedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var playlistTableView: UITableView!
    
    var searchBar: UISearchBar!
    var playlist: EPMusicPlaylist = EPMusicPlaylist()
    var filteredSongs: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.filteredSongs = NSMutableArray()
        self.playlistTableView.alpha = 0
        self.searchBar = UISearchBar(frame:CGRectMake(0, 0, 320, 44));
        self.searchBar.delegate = self
        self.playlistTableView.tableHeaderView = searchBar;
        drawRightMenuButton()
        subscribeForCacheNotifications()
        loadData()
    }

    
    func loadData() {
        let cachedTracks = EPTrack.allObjects()
        
        print("cachedTracks.count = \(cachedTracks.count)")
//        println("\(cachedTracks)")
        for trackRLM in cachedTracks {
            if let track: EPTrack = trackRLM as? EPTrack {
                print("track: \(track.artist) - \(track.title)")
            }
        }
        
        self.playlist = EPMusicPlaylist.initWithRLMResults(cachedTracks)
        self.playlistTableView.dataSource = self
        self.playlistTableView.delegate = self
        self.playlistTableView.reloadData()
        self.applyOffset()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.playlistTableView.alpha = 1
        })
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
        } else {
            self.filteredSongs = NSArray()
            self.playlistTableView.reloadData()
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
        
        var cell: UITableViewCell? = self.playlistTableView.dequeueReusableCellWithIdentifier("CellIdentifier")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CellIdentifier")
        }
        let track: EPTrack
        if (self.filteredSongs.count > 0){
            track = self.filteredSongs[indexPath.row] as! EPTrack
        } else {
            track = self.playlist.tracks[indexPath.row]
        }
        
        cell!.textLabel?.text = track.title
        cell!.detailTextLabel?.text = track.artist
        
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
        
        self.performSegueWithIdentifier("seguePlayer", sender: selectedTrack)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "seguePlayer":
//            let destinationViewController = segue.destinationViewController as! EPPlayerViewController
            
            EPMusicPlayer.sharedInstance.playTrackFromPlaylist(sender as! EPTrack, playlist: self.playlist)
        default:
            print("unknown segue")
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
