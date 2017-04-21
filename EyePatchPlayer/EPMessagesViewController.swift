//
//  EPMessagesViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 27/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPMessagesViewController: EPPlaylistAbstractViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(EPPlaylistAbstractViewController.loadData), name: NSNotification.Name(rawValue: "VK_AUTHORISED_MESSAGES"), object: nil)
        self.navigationItem.title = "Messages"
    }

    override func performAdditionalSetup() {
        shouldDrawSearchBar = false

    }

    override func loadData() {

        if !VKSdk.hasPermissions([VK_PER_MESSAGES]) {
            print("request messages permissions")
            VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_AUDIO, VK_PER_MESSAGES], revokeAccess: true, forceOAuth: false, inApp: true)
            return
        } else {
            //carry on
        }
        print("loadData messages")
        self.playlist = EPMusicPlaylist()
        self.playlist.delegate = self
        self.playlist.identifier = "Messages"
        self.tableView.dataSource = self
        self.tableView.delegate = self

        EPHTTPVKManager.getLastAudiosFromMessages(10, intermediateResultBlock: {
            (track) -> Void in
            print(track.uniqueID)
            self.playlist.addTrack(track)
            if self.playlist.trackCount == 1 {
                self.tableView.alpha = 1
            }
            self.tableView.insertRows(at: [IndexPath(row: self.playlist.trackCount - 1, section: 0)], with: UITableViewRowAnimation.right)

            self.highlightActiveTrack(false, animated: false)
        }) {
            (result, tracks) -> Void in
            print("finished parsing messages")
            self.activityIndicatorView.stopAnimating()
        }
    }
}
