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


class EPRootViewController: RESideMenu, RESideMenuDelegate, VKSdkDelegate {
    
    override func awakeFromNib() {
        print("RootViewController awakeFromNib")
        self.menuPreferredStatusBarStyle = UIStatusBarStyle.LightContent;
        self.contentViewShadowColor = UIColor.blackColor();
        self.contentViewShadowOffset = CGSizeMake(0, 0);
        self.contentViewShadowOpacity = 0.6;
        self.contentViewShadowRadius = 12;
        self.contentViewShadowEnabled = true;
        self.backgroundImage = UIImage(named: "background_leather_1")
        
        self.delegate = self
        
        self.contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RootNavigationController")
        self.rightMenuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RightMenuViewController")
        
        self.performMenuSetup()
    }
    
    func performMenuSetup() {
        self.scaleContentView = false
        self.parallaxEnabled = true
        self.menuPreferredStatusBarStyle = UIStatusBarStyle.LightContent
        self.contentViewInPortraitOffsetCenterX = +(UIScreen.mainScreen().bounds.width/2+50)
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
    }
    
    //VKSDKDelegate
    override func viewDidAppear(animated: Bool)  {
        VKSdk.initializeWithDelegate(self, andAppId: "5070798")
        
        if (VKSdk.wakeUpSession())
        {
            //Start working
            print("vk logged in")
        }
        
        if (!VKSdk.isLoggedIn()){
            print("vk is not logged in")
            VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL,VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
        }
    }
    
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        log("")
        let captchaViewController: VKCaptchaViewController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        captchaViewController.presentIn(self)
    }
    
    func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        log("")
    }
    
    func vkSdkUserDeniedAccess(authorizationError: VKError!) {
        log("")
    }
    
    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        self.presentViewController(controller, animated: true) { () -> Void in
            print("vk finished presenting controller")
        }
    }
    
    func vkSdkReceivedNewToken(newToken: VKAccessToken!) {
        log("")
        if (VKSdk.isLoggedIn()){
            let initializationRequest: VKRequest = VKApi.users().get(["fields" : "photo_200"])
            initializationRequest.executeWithResultBlock({
                (response) -> Void in
                let JSON = response.json as! NSArray
                print(JSON)
                
                }, errorBlock: { (error) -> Void in
                    print("error\(error)")
            })
            
        }
    }
    
    func vkSdkIsBasicAuthorization() -> Bool {
        return true
    }
}
