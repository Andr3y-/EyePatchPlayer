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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLogout", name: "LogoutComplete", object: nil)
        super.viewDidLoad()
        tableView = UITableView(frame: CGRectMake(self.view.frame.size.width / 1.5, (self.view.frame.size.height - 54 * CGFloat(tableEntryStrings.count)) / 2.0, self.view.frame.size.width / 1.5, 54 * CGFloat(tableEntryStrings.count)))

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

//        self.view.addSubview(tableView)
        // Do any additional setup after loading the view.
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
        var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell")

        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 21)
            cell!.textLabel!.textColor = UIColor.whiteColor()// UIColor.whiteColor()
            cell!.textLabel!.highlightedTextColor = UIColor.lightGrayColor()
            cell!.selectedBackgroundView = UIView()
        }
//        cell?.textLabel?.center = CGPointMake(((cell?.bounds.size.width)!/2), (cell?.textLabel?.center.y)!)
        cell?.textLabel?.text = tableEntryStrings[(indexPath.row)]
        cell?.textLabel?.textAlignment = NSTextAlignment.Left
        cell?.textLabel?.shadowColor = UIColor.blackColor()
        cell?.textLabel?.shadowOffset = CGSizeMake(0.0, 0.0)
//        cell?.textLabel?.font = UIFont(name:"ProximaNova-Regular", size:21.0)
//        cell?.textLabel?.layer.shadowRadius = 8.0
//        cell?.textLabel?.layer.shadowOpacity = 0.8
//        cell?.textLabel?.layer.masksToBounds = false
//        cell?.textLabel?.layer.shouldRasterize = true

        if indexPath.row == selectedItemIndex {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.applySelectionToCell(cell!)
            }
        }

        return cell!
    }

    func selectActiveCell() {
        let indexPath = NSIndexPath(forRow: selectedItemIndex, inSection: 0)
        self.applySelectionToCell(self.tableView.cellForRowAtIndexPath(indexPath)!)
    }

    func applySelectionToCell(cell: UITableViewCell) {
        let view: UIView = cell.contentView as UIView
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.frame = view.bounds
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.whiteColor().CGColor]
        gradient.startPoint = CGPointMake(0.0, 0.5)
        gradient.endPoint = CGPointMake(1.0, 0.5)

        view.layer.insertSublayer(gradient, atIndex: 0)
    }

    func clearSelectonOnCell(cell: UITableViewCell) {
        let view: UIView = cell.contentView as UIView
        if view.layer.sublayers?.count > 0 {
            view.layer.sublayers![0].removeFromSuperlayer()
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
