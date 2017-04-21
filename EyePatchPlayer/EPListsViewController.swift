//
//  FirstViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var playlistsTableView: UITableView!

    var playlists = ["My Music", "Friends", "Recommended", "Messages", "Albums"]

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Lists Loaded")

        self.playlistsTableView.delegate = self
        self.playlistsTableView.dataSource = self
        self.playlistsTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        drawRightMenuButton()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //tableview

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell? = self.playlistsTableView.dequeueReusableCell(withIdentifier: "CellIdentifier")

        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "CellIdentifier")
        }

        cell!.textLabel?.text = self.playlists[indexPath.row]

        return cell!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell: UITableViewCell = self.playlistsTableView.cellForRow(at: indexPath)!

        guard let token = VKSdk.getAccessToken(), let _ = token.userId else {
            print("unable to segue due to no user permissions (userID cannot be obtained)")
            return
        }

        if let selectedText = selectedCell.textLabel?.text {
            switch selectedText {
            case "My Music":
                self.performSegue(withIdentifier: "seguePlaylist", sender: selectedText)
                break
            case "Recommended":
                self.performSegue(withIdentifier: "segueRecommended", sender: selectedText)
                break
            case "Friends":
                self.performSegue(withIdentifier: "segueFriendList", sender: selectedText)
            case "Messages":
                self.performSegue(withIdentifier: "segueMessages", sender: selectedText)
                break
            case "Albums":
                self.performSegue(withIdentifier: "segueAlbums", sender: selectedText)
                break
            default:
                print("unhandled selection of cell with text: \(selectedText)")
                deselectRow()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let userID = Int(VKSdk.getAccessToken().userId) else {
            print("unable to segue due to no user permissions (userID cannot be obtained)")
            return
        }

        switch segue.identifier! {
        case "seguePlaylist":
            switch sender as! String {
            case "My Music":
                print("segueing to playlist (My)")
                let destinationViewController = segue.destination as! EPPlaylistViewController
                destinationViewController.userID = userID
                break
            case "Recommended":
                print("segueing to playlist (My)")
//                    let destinationViewController = segue.destinationViewController as! EPRecommendedPlaylistViewController
//                    destinationViewController.userID = userID
//                    destinationViewController.recommendedMode = true
                break
            case "Friends":
                print("segueing to Friends list")
                let destinationViewController = segue.destination as! EPFriendListViewController
                destinationViewController.userID = userID
                break
            case "Messages":
                print("segueing to Messages list")
//                    let destinationViewController = segue.destinationViewController as! EPMessagesViewController
                break
            default:
                print("segueing to ...)")

            }
            
        case "segueAlbums":
            print("segueing to Albums list")
            let destinationViewController = segue.destination as! EPAlbumListViewController
            destinationViewController.userID = userID
            break
            
        case "segueFriendList":
            let destinationViewController = segue.destination as! EPFriendListViewController
            destinationViewController.userID = userID
            break

        default:
            print("")
            break;
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deselectRow()
    }

    func deselectRow() {
        if (self.playlistsTableView.indexPathForSelectedRow != nil) {
            self.playlistsTableView.deselectRow(at: self.playlistsTableView.indexPathForSelectedRow!, animated: true)
        }
    }
}

