//
//  EPRightMenuViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 14/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class EPRightMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var selectedItemIndex: Int = 0
    let tableEntryStrings = ["Lists", "Search", "Library", "Settings"]
    
    override func viewDidLoad() {
        print("Menu: viewDidLoad")
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(EPRightMenuViewController.handleLogout), name: NSNotification.Name(rawValue: "LogoutComplete"), object: nil)
        tableView = UITableView(frame: CGRect(x: self.view.frame.size.width / 1.5, y: (self.view.frame.size.height - 54 * CGFloat(tableEntryStrings.count)) / 2.0, width: self.view.frame.size.width / 1.5, height: 54 * CGFloat(tableEntryStrings.count)))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleTopMargin]
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.isOpaque = false;
        tableView.backgroundColor = UIColor.clear;
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        tableView.bounces = false;

        // Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = UIScreen.main.bounds
        view.addSubview(blurEffectView)

        // Vibrancy Effect
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = UIScreen.main.bounds

        // Add tableView to the vibrancy view
        vibrancyEffectView.contentView.addSubview(tableView)

        // Add the vibrancy view to the blur view
        blurEffectView.contentView.addSubview(vibrancyEffectView)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableEntryStrings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = UIColor.clear
        cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 21)
        cell.textLabel!.textColor = UIColor.white// UIColor.whiteColor()
        cell.textLabel!.highlightedTextColor = UIColor.lightGray
        cell.selectedBackgroundView = UIView()
        
        cell.textLabel?.text = tableEntryStrings[(indexPath.row)]
        cell.textLabel?.textAlignment = NSTextAlignment.left
        cell.textLabel?.shadowColor = UIColor.black
        cell.textLabel?.shadowOffset = CGSize(width: 0.0, height: 0.0)

        if indexPath.row == selectedItemIndex {
            self.applySelectionToCell(cell)
        }

        return cell
    }

    func selectActiveCell() {
        let indexPath = IndexPath(row: selectedItemIndex, section: 0)
        guard let newActiveCell = self.tableView.cellForRow(at: indexPath) else {
            return
        }
        self.applySelectionToCell(newActiveCell)
    }

    func applySelectionToCell(_ cell: UITableViewCell) {
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.frame = cell.contentView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.opacity = 0
        
        cell.contentView.layer.insertSublayer(gradient, at: 0)
        
        let gradientAnimation = CABasicAnimation(keyPath: "opacity")
        gradientAnimation.fromValue = 0
        gradientAnimation.toValue = 1
        gradientAnimation.duration = 0.2
        gradientAnimation.isRemovedOnCompletion = false
        gradientAnimation.fillMode = kCAFillModeForwards
        gradient.add(gradientAnimation, forKey: "opacityAnimation")
    }

    func clearSelectonOnCell(_ cell: UITableViewCell) {
        if cell.contentView.layer.sublayers?.count > 0 {
            CATransaction.begin()
            
            let gradientAnimation = CABasicAnimation(keyPath: "opacity")
            gradientAnimation.fromValue = 1
            gradientAnimation.toValue = 0
            gradientAnimation.duration = 0.2
            gradientAnimation.isRemovedOnCompletion = false
            gradientAnimation.fillMode = kCAFillModeForwards
            
            CATransaction.setCompletionBlock({ 
                cell.contentView.layer.sublayers?[0].removeFromSuperlayer()
            })
            
            cell.contentView.layer.sublayers?[0].add(gradientAnimation, forKey: "opacityAnimation")
            
            CATransaction.commit()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)

        if indexPath.row == selectedItemIndex {
            self.sideMenuViewController.hideViewController()
            return
        } else {
            self.clearSelectonOnCell(self.tableView.cellForRow(at: IndexPath(row: selectedItemIndex, section: indexPath.section))!)
            selectedItemIndex = indexPath.row
            self.selectActiveCell()
        }

        switch indexPath.row {
        case 0:
            self.sideMenuViewController.setContentViewController(UINavigationController(rootViewController: (self.storyboard?.instantiateViewController(withIdentifier: "ListsVC"))!), animated: true)
            self.sideMenuViewController.hideViewController()
            break

        case 1:
            self.sideMenuViewController.setContentViewController(UINavigationController(rootViewController: (self.storyboard?.instantiateViewController(withIdentifier: "SearchVC"))!), animated: true)
            self.sideMenuViewController.hideViewController()
            break

        case 2:
            self.sideMenuViewController.setContentViewController(UINavigationController(rootViewController: (self.storyboard?.instantiateViewController(withIdentifier: "LibraryVC"))!), animated: true)
            self.sideMenuViewController.hideViewController()
            break

        case 3:
            self.sideMenuViewController.setContentViewController(UINavigationController(rootViewController: (self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC"))!), animated: true)
            self.sideMenuViewController.hideViewController()
            break
        default:

            break
        }
    }
    
    func handleLogout() {
        self.tableView(self.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
