//
//  EPPlaylistViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPPlaylistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var playlistTableView: EPPlaylistTableView!
    
    var userID: Int = 0
    {
        didSet {
            println("userID is set to \(userID)")
        }
        
    }
    
    var playlist: EPMusicPlaylist = EPMusicPlaylist()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log("EPPlaylistViewController, userID = \(userID)")
        
        loadData()
        // Do any additional setup after loading the view.
    }
    
    func loadData() {
        if userID != 0 {
            println("loading playlist of a user with ID: \(userID)")
            
            let audioRequest: VKRequest = VKRequest(method: "audio.get", andParameters: [VK_API_OWNER_ID : userID, VK_API_COUNT : 200, "need_user" : 0], andHttpMethod: "GET")
            audioRequest.executeWithResultBlock({ (response) -> Void in
                
                self.playlist = EPMusicPlaylist.initWithResponse(response.json as! NSDictionary)
                self.playlistTableView.dataSource = self
                self.playlistTableView.delegate = self
                
                self.playlistTableView.reloadData()
                }, errorBlock: { (error) -> Void in
                    
            })
        }
    }
    
    //tableview
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = self.playlistTableView.dequeueReusableCellWithIdentifier("CellIdentifier") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CellIdentifier")
        }
        
        let track = self.playlist.tracks[indexPath.row]
        
        cell!.textLabel?.text = track.title
        cell!.detailTextLabel?.text = track.artist
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlist.tracks.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("seguePlayer", sender: self.playlist.tracks[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
            case "seguePlayer":
            let destinationViewController = segue.destinationViewController as! EPPlayerViewController

            EPMusicPlayer.sharedInstance.playTrackFromPlaylist(sender as! EPTrack, playlist: self.playlist)
        default:
            println("unknown segue")
        }
    }
}
