//
//  EPExtrasView.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 05/11/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}

class EPExtrasView: UIView {

    @IBOutlet weak var lyricsTextView: UITextView!
    @IBAction func lyricsButtonTap(sender: AnyObject) {
        print("lyrics tap")
        updateContent()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        UIView.animateWithDuration(0.2) { () -> Void in
            self.alpha = 1
        }
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        self.alpha = 0
    }
    
    func updateContent() {
        self.hideLyrics(true)
        EPHTTPManager.getLyricsForTrack(EPMusicPlayer.sharedInstance.activeTrack) { (result, lyrics) -> Void in
            if result {
                if let lyrics = lyrics {
                    print("lyrics downloaded\n\(lyrics.body)")
                    self.lyricsTextView.text = lyrics.body
                    self.showLyrics(true)
                    return
                }
            } else {
                print("lyrics failed to download")
            }
            
            self.lyricsTextView.text = "No lyrics found"
            self.showLyrics(true)
            return
        }
    }
    
    func hideLyrics(animated: Bool) {
        UIView.animateWithDuration(animated ? 0.2 : 0.0, animations:{
            self.lyricsTextView.alpha = 0
        })
    }
    
    func showLyrics(animated: Bool) {
        UIView.animateWithDuration(animated ? 0.2 : 0.0, animations:{
            self.lyricsTextView.alpha = 1
        })
    }
    
    deinit {
        print("extras view deinit")
    }
}
