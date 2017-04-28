//
//  EPUserData.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 25/01/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import UIKit
import Crashlytics

class EPUserData: NSObject {
    
    class func setUserID(_ ID: String) {
        Crashlytics.sharedInstance().setUserIdentifier("UserID:\(ID)")
    }

}
