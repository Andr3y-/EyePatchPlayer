//
//  EPFriend.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 08/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPFriend: NSObject {
    var firstName = String()
    var lastName = String()
    var ID:Int = 0
    
    init(response:NSDictionary) {
        super.init()
        
        self.firstName = response["first_name"] as! String
        self.lastName = response["last_name"] as! String
        self.ID = response["id"] as! Int
        
    }
}
