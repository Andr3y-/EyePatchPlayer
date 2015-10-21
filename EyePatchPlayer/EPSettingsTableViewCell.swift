//
//  EPSettingsTableViewCell.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 21/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

protocol EPSettingsTableViewCellDelegate {
    func secondaryButtonTapForCell(cell: EPSettingsTableViewCell)
    func valueSwitchTapForCell(cell: EPSettingsTableViewCell)
}

class EPSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueSwitch: UISwitch!
    @IBOutlet weak var secondaryButton: UIButton!
    private var type: EPSettingType!
    
    var delegate: EPSettingsTableViewCellDelegate?
    
    func setContent(type: EPSettingType, value: Any, name: String) {
        
        switch type {
            
        case .DownloadArtwork, .ScrobbleWithLastFm, .BroadcastStatus, .SaveToPlaylist:
            
            self.secondaryButton.hidden = true
            self.valueSwitch.hidden = false
            self.valueSwitch.setOn(value as! Bool, animated: false)
            self.titleLabel.text = name
            self.type = type
            
            break
            
        case .ArtworkSize:
            self.secondaryButton.hidden = false
            self.valueSwitch.hidden = true
            self.secondaryButton.setTitle(EPSettings.preferredArtworkSizeString(), forState: .Normal)
            self.titleLabel.text = name
            self.type = type
            break
        
        }
        
        if !EPSettings.enabledStatusForSettingType(type) {
                self.userInteractionEnabled = false
            self.contentView.backgroundColor = UIColor.lightGrayColor()
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func secondaryButtonTap(sender: AnyObject) {
        if let newButtonText = EPSettings.changeSetting(self.type, value: nil) as? String {
            self.secondaryButton.setTitle(newButtonText, forState: .Normal)
        }
        
        self.delegate?.secondaryButtonTapForCell(self)
    }
    
    @IBAction func valueSwitchTap(sender: AnyObject) {
        if let newValue = EPSettings.changeSetting(self.type, value: nil) as? Bool {
            self.valueSwitch.setOn(newValue, animated: true)
        }
        self.delegate?.valueSwitchTapForCell(self)
    }
    
}
