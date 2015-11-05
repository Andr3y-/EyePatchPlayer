//
//  EPConstants.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import Foundation
struct EPConstantsClass{
    static let VKAPPID = "5070798"
    static let MUSICMATCH_API = "960b92b2b04f7d9ece5d41bf8691dfad"
}

func log(logMessage: String, functionName: String = __FUNCTION__) {
    print("\(functionName): \(logMessage)")
}