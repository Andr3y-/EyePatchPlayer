//
//  SecondViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPSearchViewController: EPPlaylistAbstractViewController {
    
    var lastExecutedSearchQuery = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shouldHideSearchBarWhenLoaded = false
        shouldIgnoreLocalSearch = true
        self.tableView.alpha = 1
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !self.searchQueryEmpty() {

            if lastExecutedSearchQuery == self.searchBar.text! {
                return
            }

            print("calling dataNotReady")
            self.dataNotReady()

            print("calling loadData")
            self.loadData()
        }
    }

    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }

    override func loadData() {
        print("loading search results for query: \(self.searchBar.text!)")

        guard let searchBarText = self.searchBar.text else {
            return
        }

        lastExecutedSearchQuery = searchBarText

        let audioRequest: VKRequest!
        let searchQuery = self.searchBar.text!
        if searchQueryEmpty() {
            audioRequest = VKRequest(method: "audio.getPopular", andParameters: ["only_eng": 1, VK_API_COUNT: 300], andHttpMethod: "GET")

        } else {
            audioRequest = VKRequest(method: "audio.search", andParameters: [VK_API_Q: self.searchBar.text!, VK_API_COUNT: 300], andHttpMethod: "GET")
        }

        audioRequest.execute(resultBlock: {
            [weak self] (response) -> Void in

            guard let strongSelf = self else {
                return
            }
            
            print("response: \(response)")
            
            if searchQuery != strongSelf.searchBar.text! {
                return
            }

            if strongSelf.searchQueryEmpty() {
                //  This is for popular
                if let responseArray = response?.json as? [[String: AnyObject]] {
                    strongSelf.playlist = EPMusicPlaylist.initWithResponseArray(responseArray as NSArray)
                }
            } else {
                //  This is for search requests
                if let responseDictionary = response?.json as? [String: AnyObject] {
                    strongSelf.playlist = EPMusicPlaylist.initWithResponse(responseDictionary as NSDictionary)
                }
            }

            if let searchText = strongSelf.searchBar.text, searchText.characters.count > 0 {
                print("reloading table")
                strongSelf.dataReady()
            } else {
                strongSelf.dataReady()
            }

            print("loadedTracks.count = \(strongSelf.playlist.tracks.count)")

        }, errorBlock: {
            (error) -> Void in

        })
    }

    func searchQueryEmpty() -> Bool {
        if let searchText = searchBar.text, searchText.characters.count > 0 {
            return false
        } else {
            return true
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlist.tracks.count
    }
}

