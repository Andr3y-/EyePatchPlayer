//
//  EPRootNavigationController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPRootNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.performWidgetSetup()
    }

    func performWidgetSetup() {
        print("performWidgetSetup")
        if let widgetViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PlayerWidget") {

            let widgetView = widgetViewController.view as! EPPlayerWidgetView
            widgetView.translatesAutoresizingMaskIntoConstraints = false
            let keyWindow = UIApplication.sharedApplication().delegate?.window

            keyWindow?!.addSubview(widgetView)
            keyWindow?!.bringSubviewToFront(widgetView)

            widgetView.topOffsetConstaint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: widgetView.superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -60)
            widgetView.superview?.addConstraint(widgetView.topOffsetConstaint)

            let leftConstraint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: widgetView.superview, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
            widgetView.superview?.addConstraint(leftConstraint)

            let widthConstraint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: (keyWindow??.bounds.width)!)
            widgetView.superview?.addConstraint(widthConstraint)

            let heightConstraint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: (keyWindow??.bounds.height)!)
            widgetView.addConstraint(heightConstraint)


            widgetView.superview?.setNeedsLayout()
            widgetView.superview?.layoutIfNeeded()

            widgetView.setNeedsLayout()
            widgetView.layoutIfNeeded()
            widgetView.layoutSubviews()

        }
    }
}
