//
//  EPRecommendedPlaylistViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 29/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPRecommendedPlaylistViewController: EPPlaylistAbstractViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Recommended"
        // Do any additional setup after loading the view.
    }

    override func loadData() {
        if let userID = VKSdk.getAccessToken().userId {
            print("loading playlist of a user with ID: \(userID)")

            let audioRequest: VKRequest = VKRequest(method: "audio.getRecommendations", andParameters: [VK_API_OWNER_ID : userID, VK_API_COUNT : 100, "shuffle" : 1], andHttpMethod: "GET")
            audioRequest.executeWithResultBlock({ (response) -> Void in

                self.playlist = EPMusicPlaylist.initWithResponse(response.json as! NSDictionary)
                self.playlist.identifier = "Recommended"
                self.dataReady()
                
                }, errorBlock: { (error) -> Void in
                    
            })
        }
    }
}
