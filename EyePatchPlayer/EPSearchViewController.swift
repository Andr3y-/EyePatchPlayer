//
//  SecondViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPSearchViewController: EPPlaylistAbstractViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        shouldHideSearchBarWhenLoaded = false
        self.tableView.alpha = 1
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchText = searchBar.text where searchText.characters.count > 0 {
            self.loadData()
        }
    }
    
    override func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    override func loadData() {
        let audioRequest: VKRequest = VKRequest(method: "audio.search", andParameters: [VK_API_Q : self.searchBar.text!, VK_API_COUNT : 100], andHttpMethod: "GET")
        audioRequest.executeWithResultBlock({ (response) -> Void in
            self.playlist = EPMusicPlaylist.initWithResponse(response.json as! NSDictionary)
            self.dataReady()
            print("loadedTracks.count = \(self.playlist.tracks.count)")

            }, errorBlock: { (error) -> Void in
                
        })
    }
}

