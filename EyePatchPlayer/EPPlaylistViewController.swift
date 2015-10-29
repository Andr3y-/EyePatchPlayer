//
//  EPPlaylistViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPPlaylistViewController: EPPlaylistAbstractViewController{
    
    var user: EPFriend?
    var userID: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.userID == Int(VKSdk.getAccessToken().userId)! {
            self.navigationItem.title = "My Music"
        } else if let user = self.user {
            self.navigationItem.title = user.firstName + "'s Music"
        }
    }
    
    override func loadData() {
        if userID != 0 {
            print("loading playlist of a user with ID: \(userID)")
            
            let audioRequest: VKRequest = VKRequest(method: "audio.get", andParameters: [VK_API_OWNER_ID : userID, VK_API_COUNT : 2000, "need_user" : 0], andHttpMethod: "GET")
            audioRequest.executeWithResultBlock({ (response) -> Void in
                
                self.playlist = EPMusicPlaylist.initWithResponse(response.json as! NSDictionary)
                self.playlist.delegate = self
                self.tableView.dataSource = self
                self.tableView.delegate = self
                self.tableView.reloadData()
                
                self.highlightActiveTrack(true, animated: false)
                
                self.applyOffset()
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.tableView.alpha = 1
                })
                }, errorBlock: { (error) -> Void in
                    print("unable to retrieve a playlist")
            })
        }
    }

}
