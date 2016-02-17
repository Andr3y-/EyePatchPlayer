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
import Parse

class EPRootViewController: RESideMenu, RESideMenuDelegate, VKSdkDelegate {

    static var sharedInstance = EPRootViewController()

    override func awakeFromNib() {
        print("RootViewController awakeFromNib")
        EPRootViewController.sharedInstance = self
//        self.menuPreferredStatusBarStyle = UIStatusBarStyle.LightContent;
        self.contentViewShadowColor = UIColor.blackColor();
        self.contentViewShadowOffset = CGSizeMake(0, 0);
        self.contentViewShadowOpacity = 0.6;
        self.contentViewShadowRadius = 12;
        self.contentViewShadowEnabled = true;
        self.backgroundImage = UIImage(named: "background_ep_gradient")
        self.scaleBackgroundImageView = false
        self.delegate = self

        self.contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RootNavigationController")
        self.rightMenuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RightMenuViewController")

        self.performMenuSetup()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLogout", name: "LogoutComplete", object: nil)
    }

    func performMenuSetup() {
        self.scaleContentView = false
        self.parallaxEnabled = true
        self.menuPreferredStatusBarStyle = UIStatusBarStyle.LightContent
        self.contentViewInPortraitOffsetCenterX = +(UIScreen.mainScreen().bounds.width / 2 + 50)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.performWidgetSetup()
    }

    func performWidgetSetup() {
        print("performWidgetSetup")
        if let widgetViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PlayerWidget") {

            let widgetView = widgetViewController.view as! EPPlayerWidgetView
            widgetView.translatesAutoresizingMaskIntoConstraints = false
            let keyWindow = UIApplication.sharedApplication().delegate?.window

            keyWindow?!.insertSubview(widgetView, atIndex: 0)

            let bottomConstraint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: widgetView.superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            widgetView.superview?.addConstraint(bottomConstraint)

            let widthConstraint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: widgetView.superview, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
            widgetView.superview?.addConstraint(widthConstraint)

            let heightConstraint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: 60)
            widgetView.addConstraint(heightConstraint)

            widgetView.setNeedsLayout()
            widgetView.layoutIfNeeded()

            widgetView.backgroundColor = UIColor.redColor()
        }
    }

    func sideMenu(sideMenu: RESideMenu!, willShowMenuViewController menuViewController: UIViewController!) {
        print("willShowMenuViewController")
    }

    func sideMenu(sideMenu: RESideMenu!, didShowMenuViewController menuViewController: UIViewController!) {
        print("didShowMenuViewController")
    }

    func sideMenu(sideMenu: RESideMenu!, willHideMenuViewController menuViewController: UIViewController!) {
        print("willHideMenuViewController")
    }

    func sideMenu(sideMenu: RESideMenu!, didHideMenuViewController menuViewController: UIViewController!) {
        print("didHideMenuViewController")
        NSNotificationCenter.defaultCenter().postNotificationName("MenuDidHide", object: nil)
    }

    //VKSDKDelegate
    override func viewDidAppear(animated: Bool) {
        VKSdk.initializeWithDelegate(self, andAppId: EPConstants.VK.AppID)

        if (VKSdk.wakeUpSession()) {
            //Start working
            print("vk logged in")

            if let token = VKSdk.getAccessToken(), let _ = token.userId {
                print("VK token & userID exist")
            } else {
                print("VK token & userID are missing, performing re-authorisation")
                VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
            }
            var email = VKSdk.getAccessToken().email
            let userID = VKSdk.getAccessToken().userId

            if VKSdk.getAccessToken().email != nil {

            } else {
                if let token2 = VKAccessToken(fromDefaults: "VKToken") {
                    let email2 = token2.email
                    if email2 != nil {
                        email = email2
                    } else {
                        email = "unknown email"
                    }
                } else {
                    email = "unknown email"
                }
            }
            EPUserData.setUserEmail("\(email)")
            EPUserData.setUserVKID(userID)
        }

        if (!VKSdk.isLoggedIn()) {
            print("vk is not logged in")
            VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
        }
    }

    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        print("")
        let captchaViewController: VKCaptchaViewController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        captchaViewController.presentIn(self)
    }

    func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        print("")
        VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
    }

    func vkSdkUserDeniedAccess(authorizationError: VKError!) {
        print("")
        if !VKSdk.hasPermissions([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_AUDIO]) {
            VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
        }
    }

    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        self.presentViewController(controller, animated: true) {
            () -> Void in
            print("vk finished presenting controller")
        }
    }

    func vkSdkReceivedNewToken(newToken: VKAccessToken!) {
        print("vkSdkReceivedNewToken")
        if (VKSdk.isLoggedIn() && VKSdk.getAccessToken() != nil) {
            NSNotificationCenter.defaultCenter().postNotificationName("LoginComplete", object: nil)
            EPUserData.setUserEmail(VKSdk.getAccessToken().email)
            EPUserData.setUserVKID(VKSdk.getAccessToken().userId)
            
            newToken.saveTokenToDefaults("VKToken")
            if VKSdk.hasPermissions([VK_PER_MESSAGES]) {
                NSNotificationCenter.defaultCenter().postNotificationName("VK_AUTHORISED_MESSAGES", object: nil)
            }
        }
    }

    func vkSdkIsBasicAuthorization() -> Bool {
        return true
    }
    
    func handleLogout() {
        VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
