//
//  FirstViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPPlaylistsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var playlistsTableView: UITableView!
    
    var playlists = ["My", "Friends", "Recommended"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log("Lists Loaded")
        
        self.playlistsTableView.delegate = self
        self.playlistsTableView.dataSource = self
        self.playlistsTableView.tableFooterView = UIView(frame: CGRectMake(0,0,1,1))
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
        if let selectedText = selectedCell.textLabel?.text {
            switch selectedText {
                case "My", "Recommended":
                    self.performSegueWithIdentifier("seguePlaylist", sender: selectedText)
                break
                case "Friends":
                    self.performSegueWithIdentifier("segueFriendList", sender: selectedText)
                break
                default:
                    print("unhandled selection of cell with text: \(selectedText)")
                    deselectRow()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
        case "seguePlaylist":
            switch sender as! String {
                case "My":
                    print("segueing to playlist (My)")
                    let destinationViewController = segue.destinationViewController as! EPPlaylistViewController
                    destinationViewController.userID = Int(VKSdk.getAccessToken().userId)!
                    break
                case "Recommended":
                    print("segueing to playlist (My)")
                    let destinationViewController = segue.destinationViewController as! EPPlaylistViewController
                    destinationViewController.userID = Int(VKSdk.getAccessToken().userId)!
                    destinationViewController.recommendedMode = true
                break
                case "Friends":
                    print("segueing to Friends list")
                    let destinationViewController = segue.destinationViewController as! EPFriendListViewController
                    destinationViewController.userID = Int(VKSdk.getAccessToken().userId)!
                    break
                
                default:
                    print("segueing to ...)")
//                    let destinationViewController = segue.destinationViewController as! EPFriendListViewController
//                    destinationViewController.userID = Int(VKSdk.getAccessToken().userId)!
            }
        case "segueFriendList":
            let destinationViewController = segue.destinationViewController as! EPFriendListViewController
            destinationViewController.userID = Int(VKSdk.getAccessToken().userId)!
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

