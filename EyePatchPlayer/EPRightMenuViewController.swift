//
//  EPRightMenuViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 14/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPRightMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var selectedItemIndex: Int = 0
    let tableEntryStrings = ["Lists", "Search", "Library", "Settings"]
    
    override func viewDidLoad() {
        print("Menu: viewDidLoad")
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EPRightMenuViewController.handleLogout), name: "LogoutComplete", object: nil)
        tableView = UITableView(frame: CGRectMake(self.view.frame.size.width / 1.5, (self.view.frame.size.height - 54 * CGFloat(tableEntryStrings.count)) / 2.0, self.view.frame.size.width / 1.5, 54 * CGFloat(tableEntryStrings.count)))

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin]
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = false;
        tableView.backgroundColor = UIColor.clearColor();
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        tableView.bounces = false;

        // Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = UIScreen.mainScreen().bounds
        view.addSubview(blurEffectView)

        // Vibrancy Effect
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = UIScreen.mainScreen().bounds

        // Add tableView to the vibrancy view
        vibrancyEffectView.contentView.addSubview(tableView)

        // Add the vibrancy view to the blur view
        blurEffectView.contentView.addSubview(vibrancyEffectView)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableEntryStrings.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel!.font = UIFont.boldSystemFontOfSize(21)
        cell.textLabel!.textColor = UIColor.whiteColor()// UIColor.whiteColor()
        cell.textLabel!.highlightedTextColor = UIColor.lightGrayColor()
        cell.selectedBackgroundView = UIView()
        
        cell.textLabel?.text = tableEntryStrings[(indexPath.row)]
        cell.textLabel?.textAlignment = NSTextAlignment.Left
        cell.textLabel?.shadowColor = UIColor.blackColor()
        cell.textLabel?.shadowOffset = CGSizeMake(0.0, 0.0)

        if indexPath.row == selectedItemIndex {
            self.applySelectionToCell(cell)
        }

        return cell
    }

    func selectActiveCell() {
        let indexPath = NSIndexPath(forRow: selectedItemIndex, inSection: 0)
        guard let newActiveCell = self.tableView.cellForRowAtIndexPath(indexPath) else {
            return
        }
        self.applySelectionToCell(newActiveCell)
    }

    func applySelectionToCell(cell: UITableViewCell) {
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.frame = cell.contentView.bounds
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.whiteColor().CGColor]
        gradient.startPoint = CGPointMake(0.0, 0.5)
        gradient.endPoint = CGPointMake(1.0, 0.5)
        gradient.opacity = 0
        
        cell.contentView.layer.insertSublayer(gradient, atIndex: 0)
        
        let gradientAnimation = CABasicAnimation(keyPath: "opacity")
        gradientAnimation.fromValue = 0
        gradientAnimation.toValue = 1
        gradientAnimation.duration = 0.2
        gradientAnimation.removedOnCompletion = false
        gradientAnimation.fillMode = kCAFillModeForwards
        gradient.addAnimation(gradientAnimation, forKey: "opacityAnimation")
    }

    func clearSelectonOnCell(cell: UITableViewCell) {
        if cell.contentView.layer.sublayers?.count > 0 {
            CATransaction.begin()
            
            let gradientAnimation = CABasicAnimation(keyPath: "opacity")
            gradientAnimation.fromValue = 1
            gradientAnimation.toValue = 0
            gradientAnimation.duration = 0.2
            gradientAnimation.removedOnCompletion = false
            gradientAnimation.fillMode = kCAFillModeForwards
            
            CATransaction.setCompletionBlock({ 
                cell.contentView.layer.sublayers?[0].removeFromSuperlayer()
            })
            
            cell.contentView.layer.sublayers?[0].addAnimation(gradientAnimation, forKey: "opacityAnimation")
            
            CATransaction.commit()
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)

        if indexPath.row == selectedItemIndex {
            self.sideMenuViewController.hideMenuViewController()
            return
        } else {
            self.clearSelectonOnCell(self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedItemIndex, inSection: indexPath.section))!)
            selectedItemIndex = indexPath.row
            self.selectActiveCell()
        }

        switch indexPath.row {
        case 0:
            self.sideMenuViewController.setContentViewController(UINavigationController(rootViewController: (self.storyboard?.instantiateViewControllerWithIdentifier("ListsVC"))!), animated: true)
            self.sideMenuViewController.hideMenuViewController()
            break

        case 1:
            self.sideMenuViewController.setContentViewController(UINavigationController(rootViewController: (self.storyboard?.instantiateViewControllerWithIdentifier("SearchVC"))!), animated: true)
            self.sideMenuViewController.hideMenuViewController()
            break

        case 2:
            self.sideMenuViewController.setContentViewController(UINavigationController(rootViewController: (self.storyboard?.instantiateViewControllerWithIdentifier("LibraryVC"))!), animated: true)
            self.sideMenuViewController.hideMenuViewController()
            break

        case 3:
            self.sideMenuViewController.setContentViewController(UINavigationController(rootViewController: (self.storyboard?.instantiateViewControllerWithIdentifier("SettingsVC"))!), animated: true)
            self.sideMenuViewController.hideMenuViewController()
            break
        default:

            break
        }
    }
    
    func handleLogout() {
        self.tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
