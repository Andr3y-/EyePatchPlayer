//
//  EPRootViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 14/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import RESideMenuWrapper
import Crashlytics

class EPRootViewController: RESideMenu, RESideMenuDelegate {

    static var sharedInstance = EPRootViewController()

    override func awakeFromNib() {
        EPRootViewController.sharedInstance = self
        self.contentViewShadowColor = UIColor.black;
        self.contentViewShadowOffset = CGSize(width: 0, height: 0);
        self.contentViewShadowOpacity = 0.6;
        self.contentViewShadowRadius = 12;
        self.contentViewShadowEnabled = true;
        self.backgroundImage = UIImage(named: "background_ep_gradient")
        self.scaleBackgroundImageView = false
        self.delegate = self

        self.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "RootNavigationController")
        self.rightMenuViewController = self.storyboard?.instantiateViewController(withIdentifier: "RightMenuViewController")

        self.performMenuSetup()
    }

    func performMenuSetup() {
        self.scaleContentView = false
        self.parallaxEnabled = true
        self.menuPreferredStatusBarStyle = UIStatusBarStyle.lightContent
        self.contentViewInPortraitOffsetCenterX = +(UIScreen.main.bounds.width / 2 + 50)
    }

    func sideMenu(_ sideMenu: RESideMenu!, willShowMenuViewController menuViewController: UIViewController!) {
        print("willShowMenuViewController")
    }

    func sideMenu(_ sideMenu: RESideMenu!, didShowMenuViewController menuViewController: UIViewController!) {
        print("didShowMenuViewController")
    }

    func sideMenu(_ sideMenu: RESideMenu!, willHideMenuViewController menuViewController: UIViewController!) {
        print("willHideMenuViewController")
    }

    func sideMenu(_ sideMenu: RESideMenu!, didHideMenuViewController menuViewController: UIViewController!) {
        print("didHideMenuViewController")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MenuDidHide"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
