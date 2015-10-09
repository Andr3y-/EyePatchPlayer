//
//  EPPlaylistViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPPlaylistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var searchBar: UISearchBar!
    @IBOutlet weak var playlistTableView: UITableView!
    
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
        
        if self.userID == Int(VKSdk.getAccessToken().userId)! {
            self.navigationItem.title = "My Music"
        } else if let user = self.user {
            self.navigationItem.title = user.firstName + "'s Music"
        }
        
        self.filteredSongs = NSMutableArray()
        self.playlistTableView.alpha = 0
        self.searchBar = UISearchBar(frame:CGRectMake(0, 0, 320, 44));
        self.searchBar.delegate = self
        self.playlistTableView.tableHeaderView = searchBar;
        log("EPPlaylistViewController, userID = \(userID)")
        
        loadData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if (searchText.characters.count>0){
        
        let predicate = NSPredicate(format: "artist contains[c] %@ OR title contains[c] %@", searchText, searchText) // if you need case sensitive search avoid '[c]' in the predicate
        let arrayCast =  self.playlist.tracks as NSArray
        self.filteredSongs = arrayCast.filteredArrayUsingPredicate(predicate) as NSArray
            self.playlistTableView.reloadData()
        } else {
            self.filteredSongs = NSArray()
            self.playlistTableView.reloadData()
        }
    }
    
    func applyOffset(){
        var contentOffset = self.playlistTableView.contentOffset
        contentOffset.y += CGRectGetHeight(self.searchBar!.frame)
        self.playlistTableView.contentOffset = contentOffset
    }
    
    func loadData() {
        if userID != 0 {
            print("loading playlist of a user with ID: \(userID)")
            
            let audioRequest: VKRequest = VKRequest(method: "audio.get", andParameters: [VK_API_OWNER_ID : userID, VK_API_COUNT : 2000, "need_user" : 0], andHttpMethod: "GET")
            audioRequest.executeWithResultBlock({ (response) -> Void in
                
                self.playlist = EPMusicPlaylist.initWithResponse(response.json as! NSDictionary)
                self.playlistTableView.dataSource = self
                self.playlistTableView.delegate = self
                self.playlistTableView.reloadData()
                self.applyOffset()
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.playlistTableView.alpha = 1
                })
                }, errorBlock: { (error) -> Void in
                    
            })
        }
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
        guard let text = searchBar.text else {
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
