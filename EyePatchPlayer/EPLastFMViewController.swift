//
//  EPLastFMViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 23/11/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import DGActivityIndicatorView

class EPLastFMViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var authorizeButton: UIButton!
    var activityIndicatorView: DGActivityIndicatorView!
    var authorized: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordTextField.delegate = self
        self.usernameTextField.delegate = self

        
        if (EPSettings.lastfmMobileSession().characters.count > 1) {
            self.authorizeButton.setTitle("Deauthorize Last.fm", forState: .Normal)
            self.usernameTextField.superview?.alpha = 0
            self.authorized = true
        }
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func authorizeButtonTap(sender: AnyObject) {
        
        self.authorizeButton.userInteractionEnabled = false
        startLoadingAnimation()
        
        if authorized {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.usernameTextField.superview?.alpha = 1
            })
            //erase authorisation signature
            EPSettings.setLastfmSession("")
            EPSettings.changeSetting(EPSettingType.ScrobbleWithLastFm, value: false)
            if let viewController = self.navigationController?.viewControllers.first {
                if let settingsViewController = viewController as? EPSettingsViewController {
                    settingsViewController.tableView.reloadData()
                }
            }
            UIView.transitionWithView(self.authorizeButton, duration: 0.2, options: .TransitionCrossDissolve, animations: { () -> Void in
                self.authorizeButton.setTitle("Authorize Last.fm", forState: .Normal)
                }, completion: nil)
            stopLoadingAnimation()
            self.authorized = false
            self.authorizeButton.userInteractionEnabled = true
        } else {
            
            if self.usernameTextField.text?.characters.count == 0 || self.passwordTextField.text?.characters.count == 0 {
                return
            }
            
            //request authorisation signature and save it
            EPHTTPManager.lastfmAuthenticate(usernameTextField.text!, password: passwordTextField.text!, completion: { (result, session) -> Void in
                if result {
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.usernameTextField.superview?.alpha = 0
                    print("sessionKey: \(session)")
                    EPSettings.setLastfmSession(session)
                    EPSettings.changeSetting(EPSettingType.ScrobbleWithLastFm, value: true)
                    if let viewController = self.navigationController?.viewControllers.first {
                        if let settingsViewController = viewController as? EPSettingsViewController {
                            settingsViewController.tableView.reloadData()
                        }
                    }
                        UIView.transitionWithView(self.authorizeButton, duration: 0.2, options: .TransitionCrossDissolve, animations: { () -> Void in
                            self.authorizeButton.setTitle("Authorized", forState: .Normal)
                            }, completion: nil)
                    })
                    self.authorized = true
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                        self.navigationController?.popViewControllerAnimated(true)
                        self.authorizeButton.userInteractionEnabled = true
                    })
                } else {
                    //handle incorrect entry or internet access
                    let alertController = UIAlertController(title: "Error", message: "Unable to authorize with these credentials", preferredStyle: .Alert)
                    let actionOk = UIAlertAction(title: "OK",
                        style: .Default,
                        handler: nil)
                    alertController.addAction(actionOk)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    self.authorizeButton.userInteractionEnabled = true
                }
                
                self.stopLoadingAnimation()
            })
            
            
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            textField.resignFirstResponder()
            self.passwordTextField.becomeFirstResponder()
            return true
        } else {
            textField.resignFirstResponder()
            return true
        }
        
    }
    
    func startLoadingAnimation() {
        activityIndicatorView = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.LineScaleParty, tintColor: UIView().tintColor, size: 30)
        self.view.addSubview(activityIndicatorView)
        //            self.view.insertSubview(activityIndicatorView, belowSubview: self.tableView)
        activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
        activityIndicatorView.startAnimating()
    }
    
    func stopLoadingAnimation() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }

}
