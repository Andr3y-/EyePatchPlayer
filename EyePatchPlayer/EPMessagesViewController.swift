//
//  EPMessagesViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 27/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPMessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, EPPlaylistDelegate, EPTrackTableViewCellDelegate {
    
    var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var playlist: EPMusicPlaylist = EPMusicPlaylist()
    var filteredSongs: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCell()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadData", name: "VK_AUTHORISED_MESSAGES", object: nil)
        self.navigationItem.title = "Messages"
        
        self.filteredSongs = NSMutableArray()
        self.tableView.alpha = 0
        
        self.searchBar = UISearchBar(frame:CGRectMake(0, 0, 320, 44));
        self.searchBar.delegate = self
        
//        self.tableView.tableHeaderView = searchBar
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0,0,1,1))
//        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        self.setupRefresh()

        //        self.tableView.allowsSelection = false
        
        drawRightMenuButton()
    
        if !VKSdk.hasPermissions([VK_PER_MESSAGES]) {
            print("request messages permissions")
            VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL,VK_PER_FRIENDS, VK_PER_AUDIO, VK_PER_MESSAGES], revokeAccess: true, forceOAuth: false, inApp: true)
            return
        } else {
            loadData()
        }
        // Do any additional setup after loading the view.
    }
    
    func loadCell() {
        let nibName = UINib(nibName: "EPTrackTableViewCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "TrackCell")
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if (searchText.characters.count>0){
            
            let predicate = NSPredicate(format: "artist contains[c] %@ OR title contains[c] %@", searchText, searchText) // if you need case sensitive search avoid '[c]' in the predicate
            let arrayCast =  self.playlist.tracks as NSArray
            self.filteredSongs = arrayCast.filteredArrayUsingPredicate(predicate) as NSArray
            self.tableView.reloadData()
            highlightActiveTrack()
            
        } else {
            self.filteredSongs = NSArray()
            self.tableView.reloadData()
            highlightActiveTrack()
        }
    }
    
    func applyOffset(){
        var contentOffset = self.tableView.contentOffset
        contentOffset.y += CGRectGetHeight(self.searchBar!.frame)
        self.tableView.contentOffset = contentOffset
    }
    
    
    func loadData() {
        print("loadData messages")
        self.playlist = EPMusicPlaylist()
        self.playlist.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
//        self.applyOffset()
        self.startRefreshing()
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.tableView.alpha = 1
        })
        
        EPHTTPManager.VKGetLastAudiosFromMessages(10, intermediateResultBlock: { (track) -> Void in
            print(track.ID)
            self.playlist.addTrack(track)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.playlist.trackCount-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
            self.highlightActiveTrack()
        }) { (result, tracks) -> Void in
            print("finished parsing messages")
            self.stopRefreshing()
        }
    }
    
    func highlightActiveTrack() {
        if EPMusicPlayer.sharedInstance.isPlaying() == true {
            if hasFilterActive() {
                for trackObject in self.filteredSongs {
                    if let track:EPTrack = trackObject as? EPTrack {
                        if track.ID == EPMusicPlayer.sharedInstance.activeTrack.ID {
                            let index = self.filteredSongs.indexOfObject(trackObject)
                            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
                        }
                    }
                }
            } else {
                for track in self.playlist.tracks {
                    if track.ID == EPMusicPlayer.sharedInstance.activeTrack.ID {
                        if let index = self.playlist.tracks.indexOf(track) {
                            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Middle)
                        }
                    }
                }
            }
        }
    }
    
    //tableview
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: EPTrackTableViewCell? = self.tableView.dequeueReusableCellWithIdentifier("TrackCell") as? EPTrackTableViewCell
        
        if cell == nil {
            cell = EPTrackTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "TrackCell")
        }
        let track: EPTrack
        if (self.filteredSongs.count > 0){
            track = self.filteredSongs[indexPath.row] as! EPTrack
        } else {
            track = self.playlist.tracks[indexPath.row]
        }
        
        cell?.delegate = self
        cell?.setupLayoutForTrack(track)
        //        cell!.setCacheStatus(track.isCached)
        cell!.titleLabel?.text = track.title
        cell!.artistLabel?.text = track.artist
        cell?.durationLabel.text = track.duration.timeInSecondsToString()
        
        if let downloadProgress = EPHTTPManager.downloadProgressForTrack(track) {
            cell!.setupDownloadProgress(downloadProgress)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let text = searchBar.text else {
            return 0
        }
        return text.characters.count > 0 ? self.filteredSongs.count : self.playlist.tracks.count
    }
    
    func hasFilterActive() -> Bool {
        
        guard let text = searchBar.text else {
            return false
        }
        
        return (text.characters.count > 0)
    }
    
    
    //EPPlaylistDelegate
    func playlistDidSetTrackActive(track:EPTrack) {
        print("playlistDidSetTrackActive")
        let index:Int?
        if self.hasFilterActive() {
            index = self.filteredSongs.indexOfObject(track)
        } else {
            index = self.playlist.tracks.indexOf(track)
        }
        
        if let indexPathsForSelectedRow = self.tableView.indexPathForSelectedRow {
            print("hasIndexPathForSelectedRow = 1")
            self.tableView.deselectRowAtIndexPath(indexPathsForSelectedRow, animated: true)
        } else {
            print("hasIndexPathForSelectedRow = 0")
        }
        
        if let index = index {
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
        }
    }
    
    //EPTrackTableViewCellDelegate
    
    func cellDetectedPrimaryTap(cell: EPTrackTableViewCell) {
        let selectedTrack: EPTrack!
        
        //        cell.setSelected(true, animated: true)
        if let indexPathsForSelectedRow = self.tableView.indexPathForSelectedRow {
            print("hasIndexPathForSelectedRow = 1")
            self.tableView.deselectRowAtIndexPath(indexPathsForSelectedRow, animated: true)
        } else {
            print("hasIndexPathForSelectedRow = 0")
        }
        
        self.tableView.selectRowAtIndexPath(self.tableView.indexPathForCell(cell), animated: true, scrollPosition: UITableViewScrollPosition.None)
        
        if let indexPath = self.tableView.indexPathForCell(cell) {
            
            if self.hasFilterActive() {
                selectedTrack = self.filteredSongs[indexPath.row] as! EPTrack
            } else {
                selectedTrack = self.playlist.tracks[indexPath.row]
            }
            
            EPMusicPlayer.sharedInstance.playTrackFromPlaylist(selectedTrack, playlist: self.playlist)
        }
    }
    
    func cellDetectedSecondaryTap(cell: EPTrackTableViewCell) {
        
        let selectedTrack: EPTrack!
        
        self.tableView.selectRowAtIndexPath(self.tableView.indexPathForCell(cell), animated: true, scrollPosition: UITableViewScrollPosition.None)
        if let indexPath = self.tableView.indexPathForCell(cell) {
            if self.hasFilterActive() {
                selectedTrack = self.filteredSongs[indexPath.row] as! EPTrack
            } else {
                selectedTrack = self.playlist.tracks[indexPath.row]
            }
            
            if selectedTrack.isCached {
                //handle is cached stuff to allow deletion in the future?
                return
            }
            cell.progressIndicatorView.progress = 0
            cell.progressIndicatorView.animateRotation(true)
            
            EPHTTPManager.downloadTrack(selectedTrack, completion: { (result, track) -> Void in
                //                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                //                cell.progressIndicatorView.animateCompletion()
                
                }, progressBlock: { (progressValue) -> Void in
                    if let progress = selectedTrack.downloadProgress {
                        progress.percentComplete = progressValue
                        //                    cell.progressIndicatorView.progress = CGFloat(progress.percentComplete)
                    }
            })
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
