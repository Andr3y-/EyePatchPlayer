//
//  FirstViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPPlaylistsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var playlistsTableView: EPPlaylistsListTableView!
    
    var playlists = ["My", "Friends"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log("EPPlaylistsListViewController")
        
        self.playlistsTableView.delegate = self
        self.playlistsTableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //tableview
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = self.playlistsTableView.dequeueReusableCellWithIdentifier("CellIdentifier") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CellIdentifier")
        }
        
        cell!.textLabel?.text = self.playlists[indexPath.row]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: UITableViewCell = self.playlistsTableView.cellForRowAtIndexPath(indexPath)!
        if let selectedText = selectedCell.textLabel?.text {
            switch selectedText {
                case "My":
                    self.performSegueWithIdentifier("seguePlaylist", sender: selectedText)

                default:
                    println("unhandled selection of cell with text: \(selectedText)")
                    deselectRow()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
        case "seguePlaylist":
            switch sender as! String {
                case "My":
                    println("segueing to playlist (My)")
                    let destinationViewController = segue.destinationViewController as! EPPlaylistViewController
                    destinationViewController.userID = VKSdk.getAccessToken().userId.toInt()!
                default:
                    println("segueing to playlist (Friend)")
                    let destinationViewController = segue.destinationViewController as! EPPlaylistViewController
                    destinationViewController.userID = VKSdk.getAccessToken().userId.toInt()!
            }
            
        default:
            println()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        deselectRow()
    }
    
    func deselectRow() {
        if (self.playlistsTableView.indexPathForSelectedRow() != nil) {
            self.playlistsTableView.deselectRowAtIndexPath(self.playlistsTableView.indexPathForSelectedRow()!, animated: true)
        }
    }
}

