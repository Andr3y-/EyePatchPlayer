//
//  EPSettingsTableViewCell.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 21/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

protocol EPSettingsTableViewCellDelegate: class {
    func secondaryButtonTapForCell(_ cell: EPSettingsTableViewCell)

    func valueSwitchTapForCell(_ cell: EPSettingsTableViewCell)
}

class EPSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueSwitch: UISwitch!
    @IBOutlet weak var secondaryButton: UIButton!
    var type: EPSettingType!

    weak var delegate: EPSettingsTableViewCellDelegate?

    func setContent(_ type: EPSettingType, value: Any, name: String) {

        switch type {

        case .downloadArtwork, .scrobbleWithLastFm, .broadcastStatus, .saveToPlaylist, .shakeToShuffle, .reverseSwipeDirection:

            self.secondaryButton.isHidden = true
            self.valueSwitch.isHidden = false
            self.valueSwitch.setOn(value as! Bool, animated: false)
            self.titleLabel.text = name
            self.type = type

            break

        case .artworkSize:
            self.secondaryButton.isHidden = false
            self.valueSwitch.isHidden = true
            self.secondaryButton.setTitle(EPSettings.preferredArtworkSizeString(), for: UIControlState())
            self.titleLabel.text = name
            self.type = type
            break
        case .equalizerActive:
            self.secondaryButton.isHidden = false
            self.valueSwitch.isHidden = true
            self.secondaryButton.setTitle(EPSettings.isEqualizerActive() ? "Active" : "Not Active", for: UIControlState())
            self.titleLabel.text = name
            self.type = type
            break
        }

        if EPSettings.isSettingAllowedDetails(type) {
            self.titleLabel?.textColor = UIView.defaultTintColor()
        }
        
        if !EPSettings.enabledStatusForSettingType(type) {
            self.isUserInteractionEnabled = false
            self.contentView.alpha = 0.3
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.valueSwitch.tintColor = UIView.defaultTintColor()
        self.valueSwitch.onTintColor = UIView.defaultTintColor()
        self.secondaryButton.tintColor = UIView.defaultTintColor()
        // Initialization code
    }

    override func prepareForReuse() {
        self.titleLabel?.textColor = .black
        self.secondaryButton.isHidden = false
        self.valueSwitch.isHidden = false
    }
    @IBAction func secondaryButtonTap(_ sender: AnyObject) {
        if self.type != nil {
            if self.type == .equalizerActive {
                if let newValue = EPSettings.changeSetting(self.type, value: nil) as? Bool {
                    self.secondaryButton.setTitle(newValue ? "Active" : "Not Active", for: UIControlState())
                }
            } else {
                if let newButtonText = EPSettings.changeSetting(self.type, value: nil) as? String {
                    self.secondaryButton.setTitle(newButtonText, for: UIControlState())
                }
            }
        }

        self.delegate?.secondaryButtonTapForCell(self)
    }

    @IBAction func valueSwitchTap(_ sender: AnyObject) {
        if self.type != nil {
            if self.type == .scrobbleWithLastFm {
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
