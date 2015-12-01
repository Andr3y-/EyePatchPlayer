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

    var playlists = ["My", "Friends", "Recommended", "Messages"]

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Lists Loaded")

        self.playlistsTableView.delegate = self
        self.playlistsTableView.dataSource = self
        self.playlistsTableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 1, 1))
        self.playlistsTableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)

        drawRightMenuButton()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //tableview

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell: UITableViewCell? = self.playlistsTableView.dequeueReusableCellWithIdentifier("CellIdentifier")

        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CellIdentifier")
        }

        cell!.textLabel?.text = self.playlists[indexPath.row]

        return cell!
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: UITableViewCell = self.playlistsTableView.cellForRowAtIndexPath(indexPath)!

        guard let token = VKSdk.getAccessToken(), let _ = token.userId else {
            print("unable to segue due to no user permissions (userID cannot be obtained)")
            return
        }

        if let selectedText = selectedCell.textLabel?.text {
            switch selectedText {
            case "My":
                self.performSegueWithIdentifier("seguePlaylist", sender: selectedText)
                break
            case "Recommended":
                self.performSegueWithIdentifier("segueRecommended", sender: selectedText)
                break
            case "Friends":
                self.performSegueWithIdentifier("segueFriendList", sender: selectedText)
            case "Messages":
                self.performSegueWithIdentifier("segueMessages", sender: selectedText)
                break
            default:
                print("unhandled selection of cell with text: \(selectedText)")
                deselectRow()
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        guard let userID = Int(VKSdk.getAccessToken().userId) else {
            print("unable to segue due to no user permissions (userID cannot be obtained)")
            return
        }

        switch segue.identifier! {
        case "seguePlaylist":
            switch sender as! String {
            case "My":
                print("segueing to playlist (My)")
                let destinationViewController = segue.destinationViewController as! EPPlaylistViewController
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
                let destinationViewController = segue.destinationViewController as! EPFriendListViewController
                destinationViewController.userID = userID
                break
            case "Messages":
                print("segueing to Messages list")
//                    let destinationViewController = segue.destinationViewController as! EPMessagesViewController
                break
            default:
                print("segueing to ...)")

            }
        case "segueFriendList":
            let destinationViewController = segue.destinationViewController as! EPFriendListViewController
            destinationViewController.userID = userID
            break

        default:
            print("")
            break;
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        deselectRow()
    }

    func deselectRow() {
        if (self.playlistsTableView.indexPathForSelectedRow != nil) {
            self.playlistsTableView.deselectRowAtIndexPath(self.playlistsTableView.indexPathForSelectedRow!, animated: true)
        }
    }
}

