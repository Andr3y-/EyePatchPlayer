//
//  EPSettingsViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EPSettingsTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCell()

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 1, 1))
        drawRightMenuButton()

    }

    func loadCell() {
        let nibName = UINib(nibName: "EPSettingsTableViewCell", bundle: nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "SettingCell")
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell: EPSettingsTableViewCell? = self.tableView.dequeueReusableCellWithIdentifier("SettingCell") as? EPSettingsTableViewCell

        if cell == nil {
            cell = EPSettingsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "SettingCell")
        }

        
        switch indexPath.row {
            
            case EPSettings.currentSettingsSet().count - 1:
                let (type, value, name) = EPSettings.currentSettingsSet()[indexPath.row]
                cell!.setContent(type, value: value, name: name)
                cell!.selectionStyle = UITableViewCellSelectionStyle.None
            
            case EPSettings.currentSettingsSet().count:
                cell!.titleLabel.text = "Log Out"
                cell!.selectionStyle = UITableViewCellSelectionStyle.None
                cell!.secondaryButton.hidden = true
                cell!.valueSwitch.hidden = true
                cell!.titleLabel.textColor = UIView.defaultTintColor()

            default:
                let (type, value, name) = EPSettings.currentSettingsSet()[indexPath.row]
                cell!.setContent(type, value: value, name: name)
                cell!.selectionStyle = UITableViewCellSelectionStyle.None
            
        }
        
        cell?.delegate = self

        return cell!
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EPSettings.currentSettingsSet().count + 1
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
        case 2:
            self.performSegueWithIdentifier("segueLastfm", sender: nil)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        case EPSettings.currentSettingsSet().count - 1:
            self.performSegueWithIdentifier("segueEqualizer", sender: nil)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        case EPSettings.currentSettingsSet().count:
            self.presentLogoutOptions()
        default:
            break
        }

    }

    func valueSwitchTapForCell(cell: EPSettingsTableViewCell) {
        if cell.type == .ScrobbleWithLastFm {
            if EPSettings.lastfmMobileSession().characters.count > 1 {
                //do nothing
            } else {
                self.performSegueWithIdentifier("segueLastfm", sender: nil)
            }
        }
    }

    func secondaryButtonTapForCell(cell: EPSettingsTableViewCell) {

    }
    
    func presentLogoutOptions() {
        let alertController = UIAlertController(title: nil, message: "Logout:\nDo you want to Remove or Keep your downloaded library?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let fullLogoutAction = UIAlertAction(title: "Remove tracks", style: .Default) { (action) in
            self.presentFullLogoutWarning()
        }
        alertController.addAction(fullLogoutAction)
        
        let accountLogoutAction = UIAlertAction(title: "Keep tracks", style: .Default) { (action) in
            self.presentExperimentalLogoutWarning()
        }
        alertController.addAction(accountLogoutAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    func presentFullLogoutWarning() {
        let alertController = UIAlertController(title: "Confirm logout?", message: "All of your downloaded tracks will be deleted.", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction) -> Void in
            print("logout cancelled")
        }
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive) { (action:UIAlertAction) -> Void in
            print("logout confirmed")
            
            EPCache.removeAllTracks()
            EPSettings.setLastfmSession("")
            EPSettings.changeSetting(EPSettingType.ScrobbleWithLastFm, value: false)
            EPHTTPTrackDownloadManager.cancelAllDownloads()
            VKSdk.forceLogout()
            EPMusicPlayer.sharedInstance.pause()
            NSNotificationCenter.defaultCenter().postNotificationName("LogoutComplete", object: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true) { () -> Void in
            
        }
    }

    func presentExperimentalLogoutWarning() {
        let alertController = UIAlertController(title: "Warning:\nConfirm account logout?", message: "All of your downloaded tracks will be SAVED. \nThis feature is experimental.", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction) -> Void in
            print("logout cancelled")
        }
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive) { (action:UIAlertAction) -> Void in
            print("logout confirmed")
            
            EPSettings.setLastfmSession("")
            EPSettings.changeSetting(EPSettingType.ScrobbleWithLastFm, value: false)
            EPHTTPTrackDownloadManager.cancelAllDownloads()
            VKSdk.forceLogout()
            EPMusicPlayer.sharedInstance.pause()
            NSNotificationCenter.defaultCenter().postNotificationName("LogoutComplete", object: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true) { () -> Void in
            
        }
    }
}
