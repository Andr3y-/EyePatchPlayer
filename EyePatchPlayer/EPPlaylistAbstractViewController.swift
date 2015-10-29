//
//  EPPlaylistAbstractViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 29/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//



import UIKit
import VK_ios_sdk

class EPPlaylistAbstractViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, EPPlaylistDelegate, EPTrackTableViewCellDelegate {
    
    var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var playlist: EPMusicPlaylist = EPMusicPlaylist()
    var filteredSongs: NSArray!
    
    private var readyToResignFirstResponder = true
    //settings for searchbar
    internal var shouldDrawSearchBar = true
    internal var shouldHideSearchBarWhenLoaded = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        loadCell()
        
        performAdditionalSetup()
        
        self.filteredSongs = NSMutableArray()
        self.tableView.alpha = 0
        
        if shouldDrawSearchBar {
            self.searchBar = UISearchBar(frame:CGRectMake(0, 0, 320, 44));
            self.searchBar.delegate = self
            self.tableView.tableHeaderView = searchBar
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0,0,1,1))
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        drawRightMenuButton()
        loadData()
    }
    
    func performAdditionalSetup() {
        
    }
    
    func loadData() {
//        if userID != 0 {
//            print("loading playlist of a user with ID: \(userID)")
//            
//            let audioRequest: VKRequest = VKRequest(method: "audio.get", andParameters: [VK_API_OWNER_ID : userID, VK_API_COUNT : 2000, "need_user" : 0], andHttpMethod: "GET")
//            audioRequest.executeWithResultBlock({ (response) -> Void in
//                
//                self.playlist = EPMusicPlaylist.initWithResponse(response.json as! NSDictionary)
//                self.playlist.delegate = self
//                self.tableView.dataSource = self
//                self.tableView.delegate = self
//                self.tableView.reloadData()
//                
//                self.highlightActiveTrack()
//                
//                self.applyOffset()
//                UIView.animateWithDuration(0.2, animations: { () -> Void in
//                    self.tableView.alpha = 1
//                })
//                }, errorBlock: { (error) -> Void in
//                    print("unable to retrieve a playlist")
//            })
//        }
    }
    
    func dataReady() {
        self.playlist.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()
        
        self.highlightActiveTrack(true, animated: true)
        
        if shouldDrawSearchBar && shouldHideSearchBarWhenLoaded {
            self.applyOffset()
        }
            
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.tableView.alpha = 1
        })
    }
    
    func loadCell() {
        let nibName = UINib(nibName: "EPTrackTableViewCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "TrackCell")
    }
    
    //MARK: Filtering & Local Search
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if (searchText.characters.count>0){
            
            filterSongsInArray()
            self.tableView.reloadData()
            highlightActiveTrack(true, animated: true)
        } else {
            self.filteredSongs = NSArray()
            self.tableView.reloadData()
            highlightActiveTrack(false, animated: false)
        }
    }
    
    func filterSongsInArray(){
        let predicate = NSPredicate(format: "artist contains[c] %@ OR title contains[c] %@", self.searchBar.text!, self.searchBar.text!) // if you need case sensitive search avoid '[c]' in the predicate
        let arrayCast =  self.playlist.tracks as NSArray
        self.filteredSongs = arrayCast.filteredArrayUsingPredicate(predicate) as NSArray
    }
    
    func highlightActiveTrack(scroll: Bool, animated: Bool) {
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
                            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: scroll ? UITableViewScrollPosition.Middle : UITableViewScrollPosition.None)
                        }
                    }
                }
            }
        }
    }
    
    func applyOffset(){
        var contentOffset = self.tableView.contentOffset
        contentOffset.y += CGRectGetHeight(self.searchBar!.frame)
        self.tableView.contentOffset = contentOffset
    }
    
    //MARK: TableView DataSource & Delegate
    
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
        
        guard let searchBarVar = searchBar, let text = searchBarVar.text else {
            return self.playlist.tracks.count
        }
        
        return text.characters.count > 0 ? self.filteredSongs.count : self.playlist.tracks.count
    }
    
    func hasFilterActive() -> Bool {
        
        guard let searchBarVar = searchBar, let text = searchBarVar.text else {
            return false
        }
        
        return (text.characters.count > 0)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //MARK: EPPlaylist Delegate
    
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
        print("cellDetectedPrimaryTap")
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
                
                }, progressBlock: { (progressValue) -> Void in
                    if let progress = selectedTrack.downloadProgress {
                        progress.percentComplete = progressValue
                    }
            })
        }
    }
    
    //hide keyboard when scrolling begins
    
    
    
    //MARK: Shaking
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canResignFirstResponder() -> Bool {
        return readyToResignFirstResponder
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        self.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("viewWillDisappear")
        super.viewWillDisappear(animated)
        readyToResignFirstResponder = true
        self.resignFirstResponder()
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake {
            print("shake detected by \(self)")
            if EPSettings.shouldDetectShakeToShuffle() {
                handleShake()
            }
        }
    }
    
    func handleShake() {
        self.playlist.reshuffle()
        self.playlist.shuffleOn = true
        
        UIView.transitionWithView(tableView,
            duration:0.2,
            options:[.CurveEaseInOut, .TransitionCrossDissolve],
            animations:
            { () -> Void in
                self.tableView.reloadData()
            },
            completion: nil)
    }
}
