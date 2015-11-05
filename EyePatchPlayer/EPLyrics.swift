//
//  EPLyrics.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 05/11/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPLyrics: AnyObject {
    
    let ID: Int!
    let body: String!
    
    init(dictionary: NSDictionary) {
        self.ID = dictionary["lyrics_id"] as? Int
        self.body = dictionary["text"] as? String
    }
}
