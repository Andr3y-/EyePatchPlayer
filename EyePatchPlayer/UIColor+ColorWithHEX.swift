//
//  UIColor+ColorWithHEX.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 04/02/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import UIKit

extension UIColor {
    class func colorWithHexString(_ HEXString: String) -> UIColor {
        var hexInt: UInt32 = 0
        let scanner = Scanner(string: HEXString)
        scanner.scanHexInt32(&hexInt)
        let color = UIColor(
            red: CGFloat((hexInt & 0xFF0000) >> 16)/225,
            green: CGFloat((hexInt & 0xFF00) >> 8)/225,
            blue: CGFloat((hexInt & 0xFF))/225,
            alpha: 1)

        return color
    }
}
