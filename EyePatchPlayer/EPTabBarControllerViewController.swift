//
//  EPTabBarControllerViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPTabBarControllerViewController: UITabBarController, VKSdkDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        log("")
        
        VKSdk.initializeWithDelegate(self, andAppId: "5070798")
        
        if (VKSdk.wakeUpSession())
        {
            //Start working
            println("vk logged in")
        }
        
        if (!VKSdk.isLoggedIn()){
            println("vk is not logged in")
//            VKSdk.authorize([VK_PER_STATS, VK_PER_EMAIL,VK_PER_FRIENDS], revokeAccess: true)
            VKSdk.authorize([VK_PER_STATS, VK_PER_STATUS, VK_PER_EMAIL,VK_PER_FRIENDS, VK_PER_AUDIO], revokeAccess: true, forceOAuth: false, inApp: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            println("vk finished presenting controller")
        }
    }
    
    func vkSdkReceivedNewToken(newToken: VKAccessToken!) {
        log("")
        if (VKSdk.isLoggedIn()){
            let initializationRequest: VKRequest = VKApi.users().get(["fields" : "photo_200"])
            initializationRequest.executeWithResultBlock({
                (response) -> Void in
                let JSON = response.json as! NSArray
                println(JSON)
                
             }, errorBlock: { (error) -> Void in
                println("error\(error)")
             })
    
        }
    }
    
    func vkSdkIsBasicAuthorization() -> Bool {
        return true
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
