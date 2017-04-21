//
//  EPTrackTableViewCellDelegate.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 12/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

protocol EPTrackTableViewCellDelegate: class {
    func cellDetectedPrimaryTap(_ cell: EPTrackTableViewCell)

    func cellDetectedSecondaryTap(_ cell: EPTrackTableViewCell)
}
