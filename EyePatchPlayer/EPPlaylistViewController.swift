//
//  EPPlaylistViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPPlaylistViewController: EPPlaylistAbstractViewController {

    var userID: Int = 0

    override func loadData() {

        if userID != 0 {
            print("loading playlist of a user with ID: \(userID)")

//            audioRequest.execute(resultBlock: {
//                (response) -> Void in
//
//                if let responseDictionary = response?.json as? NSDictionary, responseDictionary.count != 0 {
//                    self.playlist = EPMusicPlaylist.initWithResponse(responseDictionary)
//                    self.playlist.identifier = "General List"
//                }
//
//                self.dataReady()
//            }, errorBlock: {
//                (error) -> Void in
//                print("unable to retrieve a playlist\n\(String(describing: error?.localizedDescription))")
//
//                self.dataReady()
//
//                let alertController = UIAlertController(title: "Error", message: "Unable to retrieve playlist\n\(String(describing: error?.localizedDescription))", preferredStyle: .alert)
//                //We add buttons to the alert controller by creating UIAlertActions:
//                let actionOk = UIAlertAction(title: "OK",
//                        style: .default,
//                        handler: {
//                            (action) -> Void in
//                            let _ = self.navigationController?.popViewController(animated: true)
//                        }) //You can use a block here to handle a press on this button
//                alertController.addAction(actionOk)
//
//                self.present(alertController, animated: true, completion: nil)
//            })
        }
    }

}
