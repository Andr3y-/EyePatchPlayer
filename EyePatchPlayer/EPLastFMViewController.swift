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
            self.authorizeButton.setTitle("Deauthorize Last.fm", for: UIControlState())
            self.usernameTextField.superview?.alpha = 0
            self.authorized = true
        }
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func authorizeButtonTap(_ sender: AnyObject) {

        if authorized {
            self.authorizeButton.isUserInteractionEnabled = false
            startLoadingAnimation()
            UIView.animate(withDuration: 0.2, animations: {
                () -> Void in
                self.usernameTextField.superview?.alpha = 1
            })
            //erase authorisation signature
            EPSettings.setLastfmSession("")
            EPSettings.changeSetting(EPSettingType.scrobbleWithLastFm, value: false as AnyObject?)
            if let viewController = self.navigationController?.viewControllers.first {
                if let settingsViewController = viewController as? EPSettingsViewController {
                    settingsViewController.tableView.reloadData()
                }
            }
            UIView.transition(with: self.authorizeButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
                () -> Void in
                self.authorizeButton.setTitle("Authorize Last.fm", for: UIControlState())
            }, completion: nil)
            stopLoadingAnimation()
            self.authorized = false
            self.authorizeButton.isUserInteractionEnabled = true
        } else {

            if self.usernameTextField.text?.characters.count == 0 || self.passwordTextField.text?.characters.count == 0 {
                return
            }
            self.authorizeButton.isUserInteractionEnabled = false
            startLoadingAnimation()
            //request authorisation signature and save it
            EPHTTPLastFMManager.authenticate(usernameTextField.text!, password: passwordTextField.text!, completion: {
                (result, session) -> Void in
                if result {
                    UIView.animate(withDuration: 0.2, animations: {
                        () -> Void in
                        self.usernameTextField.superview?.alpha = 0
                        print("sessionKey: \(session)")
                        EPSettings.setLastfmSession(session)
                        EPSettings.changeSetting(EPSettingType.scrobbleWithLastFm, value: true as AnyObject?)
                        if let viewController = self.navigationController?.viewControllers.first {
                            if let settingsViewController = viewController as? EPSettingsViewController {
                                settingsViewController.tableView.reloadData()
                            }
                        }
                        UIView.transition(with: self.authorizeButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            () -> Void in
                            self.authorizeButton.setTitle("Authorized", for: UIControlState())
                        }, completion: nil)
                    })
                    self.authorized = true
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                        let _ = self.navigationController?.popViewController(animated: true)
                        self.authorizeButton.isUserInteractionEnabled = true
                    })
                } else {
                    //handle incorrect entry or internet access
                    let alertController = UIAlertController(title: "Error", message: "Unable to authorize with these credentials", preferredStyle: .alert)
                    let actionOk = UIAlertAction(title: "OK",
                            style: .default,
                            handler: nil)
                    alertController.addAction(actionOk)
                    self.present(alertController, animated: true, completion: nil)

                    self.authorizeButton.isUserInteractionEnabled = true
                }

                self.stopLoadingAnimation()
            })


        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
        activityIndicatorView = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.lineScaleParty, tintColor: UIView.defaultTintColor(), size: 30)
        self.view.addSubview(activityIndicatorView)
        //            self.view.insertSubview(activityIndicatorView, belowSubview: self.tableView)
        activityIndicatorView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        activityIndicatorView.startAnimating()
    }

    func stopLoadingAnimation() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }

}
