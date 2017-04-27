//
//  EPRootViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 14/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import RESideMenu
import VK_ios_sdk
import Crashlytics

class EPRootViewController: RESideMenu, RESideMenuDelegate, VKSdkDelegate {

    static var sharedInstance = EPRootViewController()

    override func awakeFromNib() {
        print("RootViewController awakeFromNib")
        EPRootViewController.sharedInstance = self
//        self.menuPreferredStatusBarStyle = UIStatusBarStyle.LightContent;
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout), name: NSNotification.Name(rawValue: "LogoutComplete"), object: nil)
    }

    func performMenuSetup() {
        self.scaleContentView = false
        self.parallaxEnabled = true
        self.menuPreferredStatusBarStyle = UIStatusBarStyle.lightContent
        self.contentViewInPortraitOffsetCenterX = +(UIScreen.main.bounds.width / 2 + 50)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.performWidgetSetup()
    }

    func performWidgetSetup() {
        print("performWidgetSetup")
        if let widgetViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerWidget") {

            let widgetView = widgetViewController.view as! EPPlayerWidgetView
            widgetView.translatesAutoresizingMaskIntoConstraints = false
            let keyWindow = UIApplication.shared.delegate?.window

            keyWindow?!.insertSubview(widgetView, at: 0)

            let bottomConstraint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: widgetView.superview, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            widgetView.superview?.addConstraint(bottomConstraint)

            let widthConstraint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: widgetView.superview, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
            widgetView.superview?.addConstraint(widthConstraint)

            let heightConstraint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: 60)
            widgetView.addConstraint(heightConstraint)

            widgetView.setNeedsLayout()
            widgetView.layoutIfNeeded()

            widgetView.backgroundColor = UIColor.red
        }
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

    //VKSDKDelegate
    override func viewDidAppear(_ animated: Bool) {
        VKSdk.initialize(with: self, andAppId: EPConstants.VK.AppID)

        if (VKSdk.wakeUpSession()) {
            //Start working
            print("vk logged in")

            if let token = VKSdk.getAccessToken(), let _ = token.userId {
                print("VK token & userID exist")
            } else {
                print("VK token & userID are missing, performing re-authorisation")
                VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
            }
            let userID = VKSdk.getAccessToken().userId

            EPUserData.setUserVKID(userID!)
        }

        if (!VKSdk.isLoggedIn()) {
            print("vk is not logged in")
            VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
        }
    }

    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("")
        let captchaViewController: VKCaptchaViewController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        captchaViewController.present(in: self)
    }

    func vkSdkTokenHasExpired(_ expiredToken: VKAccessToken!) {
        print("")
        VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
    }

    func vkSdkUserDeniedAccess(_ authorizationError: VKError!) {
        print("")
        if !VKSdk.hasPermissions([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_AUDIO]) {
            VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
        }
    }

    func vkSdkShouldPresent(_ controller: UIViewController!) {
        self.present(controller, animated: true) {
            () -> Void in
            print("vk finished presenting controller")
        }
    }

    func vkSdkReceivedNewToken(_ newToken: VKAccessToken!) {
        print("vkSdkReceivedNewToken")

        if (VKSdk.isLoggedIn() && newToken != nil && VKSdk.getAccessToken() != nil) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "LoginComplete"), object: nil)
            EPUserData.setUserVKID(VKSdk.getAccessToken().userId)
            
            newToken.save(toDefaults: "VKToken")
            if VKSdk.hasPermissions([VK_PER_MESSAGES]) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "VK_AUTHORISED_MESSAGES"), object: nil)
            }
        } else {
            print("vkSdkReceivedNewToken but token is nil")
        }
    }

    func vkSdkIsBasicAuthorization() -> Bool {
        return true
    }
    
    func handleLogout() {
        VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
