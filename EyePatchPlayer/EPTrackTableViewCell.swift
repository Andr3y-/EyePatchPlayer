//
//  EPTrackTableViewCell.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 09/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPTrackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var mainTapArea: UIView!
    @IBOutlet weak var secondaryTapArea: UIView!
    
    var delegate:EPTrackTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let primaryTapper = UITapGestureRecognizer(target: self, action: "mainTap:")
        self.mainTapArea.addGestureRecognizer(primaryTapper)
        
        let secondaryTapper = UITapGestureRecognizer(target: self, action: "secondaryTap:")
        self.secondaryTapArea.addGestureRecognizer(secondaryTapper)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func mainTap(sender: AnyObject) {
        self.delegate?.cellDetectedPrimaryTap(self)
    }
    func secondaryTap(sender: AnyObject) {
        self.delegate?.cellDetectedSecondaryTap(self)
    }
    
    func setCacheStatus(status:Bool) {
        if status {
            self.statusImageView.image = UIImage(named: "icon_tick")
        } else {
            self.statusImageView.image = UIImage(named: "icon_cross")
        }
    }
}
