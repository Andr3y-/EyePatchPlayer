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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.performWidgetSetup()
    }

    func performWidgetSetup() {
        print("performWidgetSetup")
        if let widgetViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerWidget") {

            let widgetView = widgetViewController.view as! EPPlayerWidgetView
            widgetView.translatesAutoresizingMaskIntoConstraints = false
            let keyWindow = UIApplication.shared.delegate?.window

            keyWindow?!.addSubview(widgetView)
            keyWindow?!.bringSubview(toFront: widgetView)

            widgetView.topOffsetConstaint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: widgetView.superview, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -60)
            widgetView.superview?.addConstraint(widgetView.topOffsetConstaint)

            let leftConstraint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: widgetView.superview, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
            widgetView.superview?.addConstraint(leftConstraint)

            let widthConstraint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: (keyWindow??.bounds.width)!)
            widgetView.superview?.addConstraint(widthConstraint)

            let heightConstraint = NSLayoutConstraint(item: widgetView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: (keyWindow??.bounds.height)!)
            widgetView.addConstraint(heightConstraint)


            widgetView.superview?.setNeedsLayout()
            widgetView.superview?.layoutIfNeeded()

            widgetView.setNeedsLayout()
            widgetView.layoutIfNeeded()
            widgetView.layoutSubviews()

        }
    }
}
