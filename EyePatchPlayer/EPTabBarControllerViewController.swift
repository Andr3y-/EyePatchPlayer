//
//  EPTabBarControllerViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk

class EPTabBarControllerViewController: UITabBarController, VKSdkDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("TAB BAR LOADED WHEN IT SHOULD NOT")
        VKSdk.initializeWithDelegate(self, andAppId: "5070798")
        
        if (VKSdk.wakeUpSession())
        {
            //Start working
            print("vk logged in")
            
            if let token = VKSdk.getAccessToken(), let  _ = token.userId {
                print("VK token & userID exist")
            } else {
                print("VK token & userID are missing, performing re-authorisation")
                VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL,VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
            }
            
        }
        
        if (!VKSdk.isLoggedIn()){
            print("vk is not logged in")
            VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL,VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
        }
    }
    //vkSdkDelegate
    
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
