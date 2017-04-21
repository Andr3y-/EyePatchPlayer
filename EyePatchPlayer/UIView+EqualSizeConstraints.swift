//
//  UIView+EqualSizeConstraints.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//
import UIKit

extension UIView {
    func applyEqualSizeConstraints(_ toView: UIView, includeTop: Bool) {
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal,
            toItem: toView, attribute: .left, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal,
            toItem: toView, attribute: .right, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal,
            toItem: toView, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal,
            toItem: toView, attribute: .top, multiplier: 1, constant: 0))
    }
}
