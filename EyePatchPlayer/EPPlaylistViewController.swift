//
//  EPPlaylistViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPPlaylistViewController: EPPlaylistAbstractViewController {

    var user: EPFriend?
    var userID: Int = 0
    var album: EPAlbum?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let album = album {
            self.navigationItem.title = album.title
        } else if self.userID == Int(VKSdk.getAccessToken().userId)! {
            self.navigationItem.title = "My Music"
        } else if let user = self.user {
            self.navigationItem.title = user.firstName + "'s Music"
        }
    }

    override func loadData() {
        if userID != 0 {
            print("loading playlist of a user with ID: \(userID)")

            let audioRequest: VKRequest = VKRequest(method: "audio.get", andParameters: [VK_API_OWNER_ID: userID, VK_API_COUNT: 2000, "need_user": 0, VK_API_ALBUM_ID : album != nil ? album!.ID : 0], andHttpMethod: "GET")
            audioRequest.executeWithResultBlock({
                (response) -> Void in

                if let responseDictionary = response.json as? NSDictionary where responseDictionary.count != 0 {
                    self.playlist = EPMusicPlaylist.initWithResponse(responseDictionary)
                    self.playlist.identifier = "General List"
                }

                self.dataReady()
            }, errorBlock: {
                (error) -> Void in
                print("unable to retrieve a playlist\n\(error.localizedDescription)")

                self.dataReady()

                let alertController = UIAlertController(title: "Error", message: "Unable to retrieve playlist\n\(error.localizedDescription)", preferredStyle: .Alert)
                //We add buttons to the alert controller by creating UIAlertActions:
                let actionOk = UIAlertAction(title: "OK",
                        style: .Default,
                        handler: {
                            (action) -> Void in
                            self.navigationController?.popViewControllerAnimated(true)
                        }) //You can use a block here to handle a press on this button
                alertController.addAction(actionOk)

                self.presentViewController(alertController, animated: true, completion: nil)
            })
        }
    }

}
