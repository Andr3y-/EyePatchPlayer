//
//  UIFont+Monospaced.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 19/02/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//
import UIKit

extension UIFont {
    var monospacedDigitFont: UIFont {
        let fontDescriptorFeatureSettings = [[UIFontFeatureTypeIdentifierKey: kNumberSpacingType, UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector]]
        let fontDescriptorAttributes = [UIFontDescriptorFeatureSettingsAttribute: fontDescriptorFeatureSettings]
        let oldFontDescriptor = fontDescriptor
        let newFontDescriptor = oldFontDescriptor.addingAttributes(fontDescriptorAttributes)
        
        return UIFont(descriptor: newFontDescriptor, size: 0)
    }
}
