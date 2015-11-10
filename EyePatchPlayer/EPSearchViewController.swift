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
        shouldIgnoreLocalSearch = true
        self.tableView.alpha = 1
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !self.searchQueryEmpty() {
            self.dataNotReady()
            self.loadData()
        }
    }
    
    override func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    override func loadData() {
        print("loading search results for query: \(self.searchBar.text!)")
        let audioRequest: VKRequest!
        
        if !searchQueryEmpty() {
            audioRequest = VKRequest(method: "audio.search", andParameters: [VK_API_Q : self.searchBar.text!, VK_API_COUNT : 100], andHttpMethod: "GET")
        } else {
            audioRequest = VKRequest(method: "audio.getPopular", andParameters: ["only_eng" : 1, VK_API_COUNT : 100], andHttpMethod: "GET")
        }

        audioRequest.executeWithResultBlock({ (response) -> Void in
            
            if !self.searchQueryEmpty() {
                if let responseDictionary = response.json as? NSDictionary where responseDictionary.count != 0  {
                    self.playlist = EPMusicPlaylist.initWithResponse(responseDictionary)
                }
            } else {
                if let responseArray = response.json as? NSArray where responseArray.count != 0  {
                    self.playlist = EPMusicPlaylist.initWithResponseArray(responseArray)
                }
            }
            
            if let searchText = self.searchBar.text where searchText.characters.count > 0 {
                print("reloading table")
//                self.tableView.reloadData()
                self.dataReady()
            } else {
                 self.dataReady()
            }
            
            print("loadedTracks.count = \(self.playlist.tracks.count)")

            }, errorBlock: { (error) -> Void in
                
        })
    }
    
    func searchQueryEmpty() -> Bool {
        if let searchText = searchBar.text where searchText.characters.count > 0 {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlist.tracks.count
    }
}

