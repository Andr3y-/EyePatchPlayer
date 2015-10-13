//
//  SecondViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var playlistTableView: UITableView!
    
    var searchBar: UISearchBar!
    var playlist: EPMusicPlaylist = EPMusicPlaylist()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playlistTableView.alpha = 1
        self.searchBar = UISearchBar(frame:CGRectMake(0, 0, 320, 44));
        self.searchBar.delegate = self
        self.playlistTableView.tableHeaderView = searchBar;
        // Do any additional setup after loading the view, typically from a nib.
        subscribeForCacheNotifications()
    }
    
    
    func loadData() {
        let audioRequest: VKRequest = VKRequest(method: "audio.search", andParameters: [VK_API_Q : self.searchBar.text!, VK_API_COUNT : 100], andHttpMethod: "GET")
        audioRequest.executeWithResultBlock({ (response) -> Void in
            
            self.playlist = EPMusicPlaylist.initWithResponse(response.json as! NSDictionary)
            self.playlistTableView.dataSource = self
            self.playlistTableView.delegate = self
            self.playlistTableView.reloadData()
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.playlistTableView.alpha = 1
            })
            print("loadedTracks.count = \(self.playlist.tracks.count)")

            }, errorBlock: { (error) -> Void in
                
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
        
        var cell: UITableViewCell? = self.playlistTableView.dequeueReusableCellWithIdentifier("CellIdentifier") as UITableViewCell?
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CellIdentifier")
        }
        let track: EPTrack
        
        track = self.playlist.tracks[indexPath.row]
        
        cell!.textLabel?.text = track.title
        cell!.detailTextLabel?.text = track.artist
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlist.tracks.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedTrack: EPTrack!
        
        selectedTrack = self.playlist.tracks[indexPath.row]
        
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

