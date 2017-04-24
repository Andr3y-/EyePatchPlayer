//
//  EPDownloadProgress.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 22/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPDownloadProgress: NSObject {

    dynamic var percentComplete: Double = 0
    dynamic var finished: Bool = false {
        willSet {
            self.percentComplete = 1.0
        }
    }
}
