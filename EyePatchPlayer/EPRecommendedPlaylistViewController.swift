//
//  EPRecommendedPlaylistViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 29/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPRecommendedPlaylistViewController: EPPlaylistAbstractViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Recommended"
    }

    override func loadData() {

//            audioRequest.execute(resultBlock: {
//                (response) -> Void in
//
//                if let responseDictionary = response?.json as? NSDictionary, responseDictionary.count != 0 {
//                    self.playlist = EPMusicPlaylist.initWithResponse(responseDictionary)
//                    self.playlist.identifier = "Recommended"
//                }
//
//
//                self.dataReady()
//
//            }, errorBlock: {
//                (error) -> Void in
//
//            })
    }
}
