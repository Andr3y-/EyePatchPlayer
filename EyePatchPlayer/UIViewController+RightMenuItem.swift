//
//  UIViewController+RightMenuItem.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 14/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func drawRightMenuButton() {
        
        let anotherButton = UIBarButtonItem(image:UIImage(named: "icon_burger_menu_raw_small"), style:UIBarButtonItemStyle.Plain, target:self, action:#selector(presentRightMenuViewController))
        anotherButton.tintColor = UIView.defaultTintColor()
        self.navigationItem.rightBarButtonItem = anotherButton;
    }

    
}
