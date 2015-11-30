//
//  EPExtrasView.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 05/11/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import DGActivityIndicatorView

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle: NSBundle? = nil) -> UIView? {
        return UINib(
        nibName: nibNamed,
                bundle: bundle
        ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}

class EPExtrasView: UIView {
    @IBOutlet weak var rootContentView: UIView!
    var activityIndicatorView: DGActivityIndicatorView?
    @IBOutlet weak var lyricsTextView: UITextView!
    @IBAction func lyricsButtonTap(sender: AnyObject) {
        print("lyrics tap")
        updateContent(false)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        UIView.animateWithDuration(0.2) {
            () -> Void in
            self.alpha = 1
        }
    }

    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        self.alpha = 0
    }

    func updateContent(delay: Bool) {

        if delay {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.updateContent(false)
            })
            return
        }

        self.hideLyrics(true)
        self.startLoadingAnimation()
        EPHTTPManager.getLyricsForTrack(EPMusicPlayer.sharedInstance.activeTrack) {
            (result, lyrics, trackID) -> Void in
            if trackID != EPMusicPlayer.sharedInstance.activeTrack.ID {
                return
            }
            if result {
                if let lyrics = lyrics {
                    self.lyricsTextView.text = lyrics.body
                    self.showLyrics(true)
                    self.stopLoadingAnimation()
                    return
                }
            } else {
                print("lyrics failed to download")
                self.lyricsTextView.text = "No lyrics found"
                self.showLyrics(true)
                self.stopLoadingAnimation()
            }

            return
        }
    }

    func startLoadingAnimation() {


        if activityIndicatorView == nil {
            activityIndicatorView = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.LineScaleParty, tintColor: UIView().tintColor, size: 30)
            activityIndicatorView!.tintColor = UIColor.whiteColor()

            self.rootContentView.addSubview(activityIndicatorView!)
            activityIndicatorView!.center = CGPointMake(CGRectGetMidX(self.rootContentView.bounds), CGRectGetMidY(self.rootContentView.bounds))
        }

        guard let activityIndicatorView = self.activityIndicatorView else {
            print("activityIndicatorView is nil, returning")
            return
        }

        if activityIndicatorView.animating {
            return
        }

        print("startLoadingAnimation")

        activityIndicatorView.alpha = 0
        activityIndicatorView.startAnimating()
        UIView.animateWithDuration(0.2) {
            () -> Void in
            activityIndicatorView.alpha = 1
        }
    }

    func stopLoadingAnimation() {

        guard let activityIndicatorView = self.activityIndicatorView else {
            print("activityIndicatorView is nil, returning")
            return
        }

        if !activityIndicatorView.animating {
            return
        }

        print("stopLoadingAnimation")

        activityIndicatorView.alpha = 1
        UIView.animateWithDuration(0.2, animations: {
            () -> Void in
            activityIndicatorView.alpha = 0
        }) {
            (result: Bool) -> Void in
            activityIndicatorView.stopAnimating()
            activityIndicatorView.alpha = 0
        }
    }

    func hideLyrics(animated: Bool) {
        UIView.animateWithDuration(animated ? 0.2 : 0.0, animations: {
            self.lyricsTextView.alpha = 0
        })
    }

    func showLyrics(animated: Bool) {
        UIView.animateWithDuration(animated ? 0.2 : 0.0, animations: {
            self.lyricsTextView.alpha = 1
        })
    }

    deinit {
        print("extras view deinit")
    }
}
