//
//  EPPlayerWidgetView.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import RSPlayPauseButton

class EPPlayerWidgetView: UIView, EPMusicPlayerDelegate {
    
    static var sharedInstance = EPPlayerWidgetView()
    
    var playPauseButton:RSPlayPauseButton?
    var isShown = true
    
    @IBOutlet weak var playPauseButtonPlaceholder: UIView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var progressBarPlayback: UIProgressView!

    @IBOutlet weak var interactionView: UIView!
    @IBOutlet weak var contentView: UIView!
    var playerView:UIView?
    
    var topOffsetConstaint: NSLayoutConstraint!
    
    var blurEffectView: UIVisualEffectView!
    var vibrancyEffectView: UIVisualEffectView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        EPPlayerWidgetView.sharedInstance = self
        EPMusicPlayer.sharedInstance.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "interactionTap:")
        self.interactionView.addGestureRecognizer(tapRecognizer)

        let swipeRecognizerRight = UISwipeGestureRecognizer(target: self, action: "interactionSwipe:")
        swipeRecognizerRight.direction = .Right
        self.interactionView.addGestureRecognizer(swipeRecognizerRight)
        
        let swipeRecognizerLeft = UISwipeGestureRecognizer(target: self, action: "interactionSwipe:")
        swipeRecognizerLeft.direction = .Left
        self.interactionView.addGestureRecognizer(swipeRecognizerLeft)
        print("EPPlayerWidgetView awakeFromNib")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if playPauseButton == nil {
            playPauseButton = RSPlayPauseButton(frame: playPauseButtonPlaceholder.frame)
            playPauseButton?.addTarget(self, action: "playPauseTap:", forControlEvents: UIControlEvents.TouchUpInside)
//            playPauseButton?.animationStyle = RSPlayPauseButtonAnimationStyle.SplitAndRotate
            self.playPauseButtonPlaceholder.backgroundColor = UIColor.clearColor()
            self.contentView.addSubview(playPauseButton!)
        }
        self.playPauseButton?.frame.origin = self.playPauseButtonPlaceholder.frame.origin
//        setupBlur()

    }

    //Interactions
    
    func interactionTap(sender:AnyObject) {
        print("interaction: tap")
        if isShown {
//            loadFullPlayerView()
            self.hide(true)
        } else {
            show(true)
        }
        
//        if let playerViewController = EPRootViewController.sharedInstance.storyboard?.instantiateViewControllerWithIdentifier("PlayerVC"){
//            EPRootViewController.sharedInstance.presentViewController(playerViewController, animated: true) { () -> Void in
//                //completion
//            }
//        }
    }
    
    func loadFullPlayerView() {
        print("performWidgetSetup")
        if let loadFullPlayerViewController = EPRootViewController.sharedInstance.storyboard?.instantiateViewControllerWithIdentifier("PlayerVC") {
            
            guard let playerView = loadFullPlayerViewController.view else {
                return
            }
            
            playerView.translatesAutoresizingMaskIntoConstraints = false
            let keyWindow = UIApplication.sharedApplication().delegate?.window
            
            self.addSubview(playerView)
            self.bringSubviewToFront(playerView)
            
            let leftConstraint = NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
            playerView.superview?.addConstraint(leftConstraint)

            let topConstraint = NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            playerView.superview?.addConstraint(topConstraint)
            
            let widthConstraint = NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 0, constant: (keyWindow??.bounds.width)!)
            playerView.addConstraint(widthConstraint)
            
            let heightConstraint = NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 0, constant: (keyWindow??.bounds.height)!)
            playerView.addConstraint(heightConstraint)
            
            
            playerView.superview?.setNeedsLayout()
            playerView.superview?.layoutIfNeeded()
            
            playerView.setNeedsLayout()
            playerView.layoutIfNeeded()
            playerView.layoutSubviews()
            
        }
    }
    
    func interactionSwipe(sender:UISwipeGestureRecognizer){
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Right:
            print("interaction: swipe right")

            break
            
        case UISwipeGestureRecognizerDirection.Left:
            print("interaction: swipe left")

            break
            
        default:
            
            break
        }
    }
    
    func playPauseTap(button: RSPlayPauseButton) {
//        button.setPaused(!button.paused, animated: true)
        EPMusicPlayer.sharedInstance.togglePlayPause()
    }
    
    func hide(animated:Bool) {
        if !isShown {
            print("hiding cancelled, already hidden")
            return
        } else {
            isShown = false
        }
        topOffsetConstaint.constant = -(UIApplication.sharedApplication().keyWindow?.bounds.height)!
        UIView.animateWithDuration(animated ? 0.15 : 0) { () -> Void in
            self.layoutIfNeeded()
        }
    }
    
    func show(animated:Bool) {
        if isShown {
            print("showing cancelled, already shown")
            return
        } else {
            isShown = true
        }
        topOffsetConstaint.constant = -self.contentView.bounds.height
        UIView.animateWithDuration(animated ? 0.15 : 0) { () -> Void in
            self.layoutIfNeeded()
        }
    }
    
    //EPMusicPlayerDelegate
    func playbackProgressUpdate(currentTime: Int, bufferedPercent: Double) {
        let playbackPercent = Float(currentTime) / Float(EPMusicPlayer.sharedInstance.activeTrack.duration)
        self.progressBarPlayback.setProgress(playbackPercent, animated: false)
    }
    
    func playbackStatusUpdate(playbackStatus: PlaybackStatus) {
        print("EPPlayerWidgetView: playbackStatusUpdate: \(playbackStatus)")
        switch playbackStatus {
        case PlaybackStatus.Play:
            self.playPauseButton?.setPaused(false, animated: true)
            
            
        case PlaybackStatus.Pause:
            self.playPauseButton?.setPaused(!false, animated: true)

            
        default:
            self.playPauseButton?.setPaused(!false, animated: true)

        }
    }
    
    func playbackTrackUpdate() {
        print("EPPlayerWidgetView: playbackTrackUpdate")
        updateUIForNewTrack()
    }
    
    func trackCachedWithResult(result: Bool) {
        //not handling here
    }
    
    func trackRetrievedArtworkImage(image: UIImage) {
        print("trackRetrievedArtworkImage")
        setArtworkImage(image)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.albumArtImageView.alpha = 1.0
        })
    }
    
    //UI Updates
    func updateUIForNewTrack(){
        if EPMusicPlayer.sharedInstance.activeTrack.artworkImage() == nil {
            setPlaceholderArtworkImage()
        } else {
            setArtworkImage(EPMusicPlayer.sharedInstance.activeTrack.artworkImage()!)
        }
        
//        self.currentTimeLabel.text = "00:00"
//        self.maxTimeLabel.text = timeInSecondsToString(EPMusicPlayer.sharedInstance.activeTrack.duration)
        
        self.artistLabel.text = EPMusicPlayer.sharedInstance.activeTrack.artist;
        self.titleLabel.text = EPMusicPlayer.sharedInstance.activeTrack.title
        
        self.progressBarPlayback.setProgress(0, animated: false)
        
        print("updateUIForNewTrack - complete")
    }

    func setPlaceholderArtworkImage(){
        UIView.transitionWithView(self.albumArtImageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.albumArtImageView.image = UIImage(named: "icon_cover_placeholder_1")
            }, completion: nil)
    }
    
    func setArtworkImage(image:UIImage) {
        UIView.transitionWithView(self.albumArtImageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.albumArtImageView.image = image
            }, completion: nil)
    }
}
