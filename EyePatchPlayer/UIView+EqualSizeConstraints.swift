//
//  UIView+EqualSizeConstraints.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//
import UIKit

extension UIView {
    func applyEqualSizeConstraints(toView: UIView, includeTop: Bool) {
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal,
            toItem: toView, attribute: .Left, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal,
            toItem: toView, attribute: .Right, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal,
            toItem: toView, attribute: .Bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal,
            toItem: toView, attribute: .Top, multiplier: 1, constant: 0))
    }
}