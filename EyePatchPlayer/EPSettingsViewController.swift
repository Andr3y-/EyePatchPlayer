//
//  EPSettingsViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EPSettingsTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCell()

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        drawRightMenuButton()

    }

    func loadCell() {
        let nibName = UINib(nibName: "EPSettingsTableViewCell", bundle: nil)
        self.tableView.register(nibName, forCellReuseIdentifier: "SettingCell")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: EPSettingsTableViewCell? = self.tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? EPSettingsTableViewCell

        if cell == nil {
            cell = EPSettingsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "SettingCell")
        }

        
        switch indexPath.row {
            
            case EPSettings.currentSettingsSet().count - 1:
                let (type, value, name) = EPSettings.currentSettingsSet()[indexPath.row]
                cell!.setContent(type, value: value, name: name)
                cell!.selectionStyle = UITableViewCellSelectionStyle.none
            
            case EPSettings.currentSettingsSet().count:
                cell!.titleLabel.text = "Log Out"
                cell!.selectionStyle = UITableViewCellSelectionStyle.none
                cell!.secondaryButton.isHidden = true
                cell!.valueSwitch.isHidden = true
                cell!.titleLabel.textColor = UIView.defaultTintColor()

            default:
                let (type, value, name) = EPSettings.currentSettingsSet()[indexPath.row]
                cell!.setContent(type, value: value, name: name)
                cell!.selectionStyle = UITableViewCellSelectionStyle.none
            
        }
        
        cell?.delegate = self

        return cell!
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EPSettings.currentSettingsSet().count + 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 2:
            self.performSegue(withIdentifier: "segueLastfm", sender: nil)
            self.tableView.deselectRow(at: indexPath, animated: true)
        case EPSettings.currentSettingsSet().count - 1:
            self.performSegue(withIdentifier: "segueEqualizer", sender: nil)
            self.tableView.deselectRow(at: indexPath, animated: true)
        case EPSettings.currentSettingsSet().count:
            self.presentLogoutOptions()
        default:
            break
        }

    }

    func valueSwitchTapForCell(_ cell: EPSettingsTableViewCell) {
        if cell.type == .scrobbleWithLastFm {
            if EPSettings.lastfmMobileSession().characters.count > 1 {
                //do nothing
            } else {
                self.performSegue(withIdentifier: "segueLastfm", sender: nil)
            }
        }
    }

    func secondaryButtonTapForCell(_ cell: EPSettingsTableViewCell) {

    }
    
    func presentLogoutOptions() {
        let alertController = UIAlertController(title: nil, message: "Logout:\nDo you want to Remove or Keep your downloaded library?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let fullLogoutAction = UIAlertAction(title: "Remove tracks", style: .default) { (action) in
            self.presentFullLogoutWarning()
        }
        alertController.addAction(fullLogoutAction)
        
        let accountLogoutAction = UIAlertAction(title: "Keep tracks", style: .default) { (action) in
            self.presentExperimentalLogoutWarning()
        }
        alertController.addAction(accountLogoutAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func presentFullLogoutWarning() {
        let alertController = UIAlertController(title: "Confirm logout?", message: "All of your downloaded tracks will be deleted.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) -> Void in
            print("logout cancelled")
        }
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive) { (action:UIAlertAction) -> Void in
            print("logout confirmed")
            
            EPCache.removeAllTracks()
            EPSettings.setLastfmSession("")
            EPSettings.changeSetting(EPSettingType.scrobbleWithLastFm, value: false as AnyObject?)
            EPHTTPTrackDownloadManager.cancelAllDownloads()
            EPMusicPlayer.sharedInstance.pause()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "LogoutComplete"), object: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true) { () -> Void in
            
        }
    }

    func presentExperimentalLogoutWarning() {
        let alertController = UIAlertController(title: "Warning:\nConfirm account logout?", message: "All of your downloaded tracks will be SAVED. \nThis feature is experimental.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) -> Void in
            print("logout cancelled")
        }
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive) { (action:UIAlertAction) -> Void in
            print("logout confirmed")
            
            EPSettings.setLastfmSession("")
            EPSettings.changeSetting(EPSettingType.scrobbleWithLastFm, value: false as AnyObject?)
            EPHTTPTrackDownloadManager.cancelAllDownloads()
            EPMusicPlayer.sharedInstance.pause()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "LogoutComplete"), object: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true) { () -> Void in
            
        }
    }
}
