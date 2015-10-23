//
//  EPPlaylistViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPPlaylistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, EPPlaylistDelegate, EPTrackTableViewCellDelegate {
    
    var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var user: EPFriend?
    var userID: Int = 0
    {
        didSet {
            print("userID is set to \(userID)")
        }
    }
    
    var playlist: EPMusicPlaylist = EPMusicPlaylist()
    var filteredSongs: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCell()
        
        if self.userID == Int(VKSdk.getAccessToken().userId)! {
            self.navigationItem.title = "My Music"
        } else if let user = self.user {
            self.navigationItem.title = user.firstName + "'s Music"
        }
        
        self.filteredSongs = NSMutableArray()
        self.tableView.alpha = 0
        self.searchBar = UISearchBar(frame:CGRectMake(0, 0, 320, 44));
        self.searchBar.delegate = self
        
        self.tableView.tableHeaderView = searchBar
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0,0,1,1))
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        self.tableView.allowsSelection = false
        
        log("EPPlaylistViewController, userID = \(userID)")
        drawRightMenuButton()
        loadData()
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
        if userID != 0 {
            print("loading playlist of a user with ID: \(userID)")
            
            let audioRequest: VKRequest = VKRequest(method: "audio.get", andParameters: [VK_API_OWNER_ID : userID, VK_API_COUNT : 2000, "need_user" : 0], andHttpMethod: "GET")
            audioRequest.executeWithResultBlock({ (response) -> Void in
                
                self.playlist = EPMusicPlaylist.initWithResponse(response.json as! NSDictionary)
                self.playlist.delegate = self
                self.tableView.dataSource = self
                self.tableView.delegate = self
                self.tableView.reloadData()
                
                self.highlightActiveTrack()
                
                self.applyOffset()
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.tableView.alpha = 1
                })
                }, errorBlock: { (error) -> Void in
                    
            })
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
//            self.performSegueWithIdentifier("seguePlayer", sender: selectedTrack)
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
