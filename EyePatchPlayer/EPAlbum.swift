//
//  EPAlbum.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 19/02/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import Mantle

class EPAlbum: MTLModel, MTLJSONSerializing {
    
    var ID:Int = 0
    var ownerID:Int = 0
    var title:String = ""
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            "ID" : "id",
            "ownerID" : "owner_id",
            "title" : "title"
        ]
    }
    
}
