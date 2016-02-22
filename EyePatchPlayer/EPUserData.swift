//
//  EPUserData.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 25/01/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import UIKit
import Parse
import Crashlytics
import VK_ios_sdk

class EPUserData: NSObject {
    
    class func setUserVKID(vkID: String) {
        
        Crashlytics.sharedInstance().setUserIdentifier("VKID:\(vkID)")
        
        if let currentUser = PFUser.currentUser() {
            //user existing one
            currentUser["VKID"] = vkID
            currentUser.saveInBackground()
        } else {
            //register one from scratch
            PFAnonymousUtils.logInWithBlock({ (user: PFUser?, error:NSError?) -> Void in
                if (error != nil) {
                    print("parse anonynoums login succeeded")
                    if let user = user {
                        user["VKID"] = vkID
                        user.saveInBackground()
                    }
                } else {
                    print("parse anonymous login failed")
                }
            })
        }
    }
    
    class func VKID() -> String! {
        if let currentUser = PFUser.currentUser() {
            //user existing one
            if let vkID = currentUser["VKID"] as? String {
                return vkID
            }
        }
        
        return VKSdk.getAccessToken().userId
    }
}
