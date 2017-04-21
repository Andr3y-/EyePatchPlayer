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
    class func loadFromNibNamed(_ nibNamed: String, bundle: Bundle? = nil) -> UIView? {
        return UINib(
        nibName: nibNamed,
                bundle: bundle
        ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}

class EPExtrasView: UIView {
    @IBOutlet weak var rootContentView: UIView!
    var activityIndicatorView: DGActivityIndicatorView?
    @IBOutlet weak var lyricsTextView: UITextView!
    @IBAction func lyricsButtonTap(_ sender: AnyObject) {
        print("lyrics tap")
        updateContent(false)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        UIView.animate(withDuration: 0.2, animations: {
            () -> Void in
            self.alpha = 1
        }) 
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.alpha = 0
    }

    func updateContent(_ delay: Bool) {

        if delay {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.updateContent(false)
            })
            return
        }

        self.hideLyrics(true)
        self.startLoadingAnimation()
        EPHTTPVKManager.getLyricsForTrack(EPMusicPlayer.sharedInstance.activeTrack) {
            (result, lyrics, trackUniqueID) -> Void in
            if trackUniqueID != EPMusicPlayer.sharedInstance.activeTrack.uniqueID {
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
            activityIndicatorView = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.lineScaleParty, tintColor: UIView.defaultTintColor(), size: 30)
            activityIndicatorView!.tintColor = UIColor.white

            self.rootContentView.addSubview(activityIndicatorView!)
            activityIndicatorView!.center = CGPoint(x: self.rootContentView.bounds.midX, y: self.rootContentView.bounds.midY)
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
        UIView.animate(withDuration: 0.2, animations: {
            () -> Void in
            activityIndicatorView.alpha = 1
        }) 
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
        UIView.animate(withDuration: 0.2, animations: {
            () -> Void in
            activityIndicatorView.alpha = 0
        }, completion: {
            (result: Bool) -> Void in
            activityIndicatorView.stopAnimating()
            activityIndicatorView.alpha = 0
        }) 
    }

    func hideLyrics(_ animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: {
            self.lyricsTextView.alpha = 0
        })
    }

    func showLyrics(_ animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: {
            self.lyricsTextView.alpha = 1
        })
    }

    deinit {
        print("extras view deinit")
    }
}
