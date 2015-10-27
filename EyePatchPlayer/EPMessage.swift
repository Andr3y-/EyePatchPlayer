//
//  EPMessage.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 26/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPMessage: NSObject {
    
    var ID: Int
    var date: Int
    var userID: Int
    var attachments: [EPMessageAttachment]?
    
    init(response: NSDictionary) {
        
        self.ID = response["id"] as! Int
        self.date = response["date"] as! Int
        self.userID = response["user_id"] as! Int
        
        if let attachmentsArray = response["attachments"] as? [NSDictionary] {
            for attachmentJSON in attachmentsArray {
                let attachment = EPMessageAttachment(response: attachmentJSON)
                
                if self.attachments == nil {
                    self.attachments = [EPMessageAttachment]()
                }
                
                self.attachments!.append(attachment)
            }
        }
        
        super.init()
    }
}

class EPMessageAttachment: NSObject {
    
    var type: AttachmentType!
    var object: AnyObject!
    
    init(response: NSDictionary) {
        let typeString = response["type"] as! String
        
        switch typeString {
        case AttachmentType.Audio.rawValue:
            self.type = .Audio
            self.object = EPTrack.initWithResponse(response[AttachmentType.Audio.rawValue] as! NSDictionary)
            break
        case AttachmentType.Video.rawValue:
            self.type = .Video
            self.object = response[AttachmentType.Video.rawValue] as! NSDictionary
            break
        case AttachmentType.Photo.rawValue:
            self.type = .Photo
            self.object = response[AttachmentType.Photo.rawValue] as! NSDictionary
            break
        case AttachmentType.Link.rawValue:
            self.type = .Link
            self.object = response[AttachmentType.Link.rawValue] as! NSDictionary
            break
        default:
            self.type = .Unknown
            break
        }
        
        super.init()
    }
}

enum AttachmentType: String {
    case Audio = "audio"
    case Video = "video"
    case Photo = "photo"
    case Link = "link"
    case Unknown = "unknown"
}