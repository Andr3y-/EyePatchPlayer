//
//  EPSettingsTableViewCell.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 21/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

protocol EPSettingsTableViewCellDelegate: class {
    func secondaryButtonTapForCell(cell: EPSettingsTableViewCell)

    func valueSwitchTapForCell(cell: EPSettingsTableViewCell)
}

class EPSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueSwitch: UISwitch!
    @IBOutlet weak var secondaryButton: UIButton!
    var type: EPSettingType!

    weak var delegate: EPSettingsTableViewCellDelegate?

    func setContent(type: EPSettingType, value: Any, name: String) {

        switch type {

        case .DownloadArtwork, .ScrobbleWithLastFm, .BroadcastStatus, .SaveToPlaylist, .ShakeToShuffle, .ReverseSwipeDirection:

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
        case .EqualizerActive:
            self.secondaryButton.hidden = false
            self.valueSwitch.hidden = true
            self.secondaryButton.setTitle(EPSettings.isEqualizerActive() ? "Active" : "Not Active", forState: .Normal)
            self.titleLabel.text = name
            self.type = type
            break
        }

        if !EPSettings.enabledStatusForSettingType(type) {
            self.userInteractionEnabled = false
            self.contentView.alpha = 0.3

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
        if self.type != nil {
            if self.type == .EqualizerActive {
                if let newValue = EPSettings.changeSetting(self.type, value: nil) as? Bool {
                    self.secondaryButton.setTitle(newValue ? "Active" : "Not Active", forState: .Normal)
                }
            } else {
                if let newButtonText = EPSettings.changeSetting(self.type, value: nil) as? String {
                    self.secondaryButton.setTitle(newButtonText, forState: .Normal)
                }
            }
        }

        self.delegate?.secondaryButtonTapForCell(self)
    }

    @IBAction func valueSwitchTap(sender: AnyObject) {
        if self.type != nil {
            if self.type == .ScrobbleWithLastFm {
                if EPSettings.lastfmMobileSession().characters.count > 1 {
                    if let newValue = EPSettings.changeSetting(self.type, value: nil) as? Bool {
                        self.valueSwitch.setOn(newValue, animated: true)
                    }
                } else {
                    //do nothing
                    self.valueSwitch.setOn(false, animated: true)
                }
            } else {
                if let newValue = EPSettings.changeSetting(self.type, value: nil) as? Bool {
                    self.valueSwitch.setOn(newValue, animated: true)
                }
            }

        }
        self.delegate?.valueSwitchTapForCell(self)
    }

}
