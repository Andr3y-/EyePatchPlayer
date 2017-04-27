//
//  EPUserData.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 25/01/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import UIKit
import Crashlytics
import VK_ios_sdk

class EPUserData: NSObject {
    
    class func setUserVKID(_ vkID: String) {
        Crashlytics.sharedInstance().setUserIdentifier("VKID:\(vkID)")
    }
    
    class func VKID() -> String! {
        return VKSdk.getAccessToken().userId
    }
}
