//
//  EPMessagesViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 27/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPMessagesViewController: EPPlaylistAbstractViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadData", name: "VK_AUTHORISED_MESSAGES", object: nil)
        self.navigationItem.title = "Messages"
    }
    
    override func performAdditionalSetup() {
        shouldDrawSearchBar = false
//        self.setupRefresh(false)
    }
    
    override func loadData() {
        
        if !VKSdk.hasPermissions([VK_PER_MESSAGES]) {
            print("request messages permissions")
            VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL,VK_PER_FRIENDS, VK_PER_AUDIO, VK_PER_MESSAGES], revokeAccess: true, forceOAuth: false, inApp: true)
            return
        } else {
            //carry on
        }
        print("loadData messages")
        self.playlist = EPMusicPlaylist()
        self.playlist.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        EPHTTPManager.VKGetLastAudiosFromMessages(10, intermediateResultBlock: { (track) -> Void in
            print(track.ID)
            self.playlist.addTrack(track)
            if self.playlist.trackCount == 1 {
                self.tableView.alpha = 1
            }
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.playlist.trackCount-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)

            self.highlightActiveTrack(false, animated: false)
        }) { (result, tracks) -> Void in
            print("finished parsing messages")
            self.activityIndicatorView.stopAnimating()
        }
    }
}
