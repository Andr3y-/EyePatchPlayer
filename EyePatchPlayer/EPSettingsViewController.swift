//
//  EPSettingsViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCell()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
//        self.tableView.allowsSelection = false
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0,0,1,1))
        drawRightMenuButton()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func loadCell() {
        let nibName = UINib(nibName: "EPSettingsTableViewCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "SettingCell")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: EPSettingsTableViewCell? = self.tableView.dequeueReusableCellWithIdentifier("SettingCell") as? EPSettingsTableViewCell
        
        if cell == nil {
            cell = EPSettingsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "SettingCell")
        }

        if indexPath.row != EPSettings.currentSettingsSet().count-1 {
            let (type, value, name) = EPSettings.currentSettingsSet()[indexPath.row]
            cell!.setContent(type, value: value, name: name)
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
        } else {
            let (type, value, name) = EPSettings.currentSettingsSet()[indexPath.row]
            cell!.setContent(type, value: value, name: name)
        }
        
   
        return cell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EPSettings.currentSettingsSet().count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == EPSettings.currentSettingsSet().count-1 {//eq row
            self.performSegueWithIdentifier("segueEqualizer", sender: nil)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}

/*

shouldAutomaticallySaveToPlaylist
shouldBroadcastStatus
shoulScrobbleWithLastFm
shouldDownloadArtwork
preferredArtworkSizeEnum

*/