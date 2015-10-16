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
    
    var isShown = true
    
    var topOffsetConstaint: NSLayoutConstraint!

    //widget view
    var playPauseButton:RSPlayPauseButton?
    @IBOutlet weak var playPauseButtonPlaceholder: UIView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var progressBarPlayback: UIProgressView!

    @IBOutlet weak var interactionView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    //mainView
    @IBOutlet weak var playerHeaderView: UIView!
    @IBOutlet weak var albumArtImageViewBig: UIImageView!
    @IBOutlet weak var progressBarPlaybackBig: UIProgressView!
    @IBOutlet weak var leftPlaybackTimeLabel: UILabel!
    @IBOutlet weak var rightPlaybackTimeLabel: UILabel!
    
    var playPauseButtonBig:RSPlayPauseButton?
    @IBOutlet weak var playPauseButtonPlaceholderBig: UIView!
    @IBOutlet weak var artistLabelBig: UILabel!
    @IBOutlet weak var titleLabelBig: UILabel!
    @IBOutlet weak var shuffleSwitch: UISwitch!
    @IBOutlet weak var cacheButton: UIButton!
    
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var backgroundAlbumArtImageView: UIImageView!
    @IBOutlet weak var vibrancyContentView: UIView!
    
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
            self.playPauseButtonPlaceholder.backgroundColor = UIColor.clearColor()
            self.contentView.addSubview(playPauseButton!)
        }
        
        if playPauseButtonBig == nil {
            playPauseButtonBig = RSPlayPauseButton(frame: playPauseButtonPlaceholderBig.frame)
            playPauseButtonBig?.addTarget(self, action: "playPauseTap:", forControlEvents: UIControlEvents.TouchUpInside)
            self.playPauseButtonPlaceholderBig.backgroundColor = UIColor.clearColor()
            self.vibrancyContentView.addSubview(playPauseButtonBig!)
        }
        self.playPauseButtonBig?.frame.origin = self.playPauseButtonPlaceholderBig.frame.origin
        self.playPauseButton?.frame.origin = self.playPauseButtonPlaceholder.frame.origin

    }
    
    func processViews() {
        for view in [leftPlaybackTimeLabel, rightPlaybackTimeLabel, artistLabelBig, titleLabelBig, shuffleSwitch, cacheButton] {
            if view.superview! != self.vibrancyContentView {
               
                let oldFrame = view.frame
                let newRect = view.convertRect(view.bounds, toView: self.vibrancyContentView)
                view.removeConstraints(view.constraints)
                 print("old: \(oldFrame)")
                 print("new: \(newRect)")
                self.vibrancyContentView.addSubview(view)
                view.frame = newRect
            }
        }
    }
    
    //Interactions
    
    func interactionTap(sender:AnyObject) {
        print("interaction: tap")
//        processViews()
        if isShown {
            self.hide(true)
        } else {
            show(true)
        }
        
    }
    @IBAction func hideButtonTap(sender: UIButton) {
        if isShown {
            self.hide(true)
        } else {
            show(true)
        }
    }
    
    func loadFullPlayerView() {
        
    }
    
    func interactionSwipe(sender:UISwipeGestureRecognizer){
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Right:
            EPMusicPlayer.sharedInstance.playNextSong()
            print("interaction: swipe right")

            break
            
        case UISwipeGestureRecognizerDirection.Left:
            EPMusicPlayer.sharedInstance.playPrevSong()
            print("interaction: swipe left")

            break
            
        default:
            
            break
        }
    }
    
    @IBAction func cacheButtonTap(sender: AnyObject) {
        switch EPMusicPlayer.sharedInstance.activeTrack.isCached {
        case true:
            self.cacheButton.setTitle("Cached", forState: UIControlState.Normal)
            print("removal requested")
            break
        default:
            EPHTTPManager.downloadTrack(EPMusicPlayer.sharedInstance.activeTrack, completion: { (result, track) -> Void in
                if result && EPMusicPlayer.sharedInstance.activeTrack.ID == track.ID {
                    self.trackCachedWithResult(true)
                } else {
                    self.trackCachedWithResult(false)
                }
                
                }, progressBlock: { (progressValue) -> Void in
                    //                    println("download: \(progressValue * 100) %")
            })
            self.cacheButton.setTitle("Saving", forState: UIControlState.Normal)
            break
        }
    }
    func playPauseTap(button: RSPlayPauseButton) {
        EPMusicPlayer.sharedInstance.togglePlayPause()
    }
    
    @IBAction func nextTrackTap(sender: AnyObject) {
        EPMusicPlayer.sharedInstance.playNextSong()
    }
    
    @IBAction func prevTrackTap(sender: AnyObject) {
        EPMusicPlayer.sharedInstance.playPrevSong()
    }
    
    @IBAction func shuffleSwitchValueChanged(sender: UISwitch) {
        EPMusicPlayer.sharedInstance.playlist.shuffleOn = sender.on
    }
    
    func hide(animated:Bool) {
        if !isShown {
            print("hiding cancelled, already hidden")
            return
        } else {
            isShown = false
        }
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        topOffsetConstaint.constant = -(UIApplication.sharedApplication().keyWindow?.bounds.height)!
        UIView.animateWithDuration(animated ? 0.15 : 0) { () -> Void in
            self.layoutIfNeeded()
            self.contentView.alpha = 0
        }
    }
    
    func show(animated:Bool) {
        if isShown {
            print("showing cancelled, already shown")
            return
        } else {
            isShown = true
        }
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        topOffsetConstaint.constant = -self.contentView.bounds.height
        UIView.animateWithDuration(animated ? 0.15 : 0) { () -> Void in
            self.layoutIfNeeded()
            self.contentView.alpha = 1
        }
    }
    
    //EPMusicPlayerDelegate
    func playbackProgressUpdate(currentTime: Int, bufferedPercent: Double) {
        let playbackPercent = Float(currentTime) / Float(EPMusicPlayer.sharedInstance.activeTrack.duration)
        
        self.leftPlaybackTimeLabel.text = currentTime.timeInSecondsToString()
        self.rightPlaybackTimeLabel.text = (EPMusicPlayer.sharedInstance.activeTrack.duration-currentTime).timeInSecondsToString()

        self.progressBarPlayback.setProgress(playbackPercent, animated: false)
        self.progressBarPlaybackBig.setProgress(playbackPercent, animated: false)
    }
    
    func playbackStatusUpdate(playbackStatus: PlaybackStatus) {
        print("EPPlayerWidgetView: playbackStatusUpdate: \(playbackStatus)")
        switch playbackStatus {
        case PlaybackStatus.Play:
            self.playPauseButton?.setPaused(false, animated: true)
            self.playPauseButtonBig?.setPaused(false, animated: true)
            
        case PlaybackStatus.Pause:
            self.playPauseButton?.setPaused(!false, animated: true)
            self.playPauseButtonBig?.setPaused(!false, animated: true)
            
        default:
            self.playPauseButton?.setPaused(!false, animated: true)
            self.playPauseButtonBig?.setPaused(!false, animated: true)
        }
    }
    
    func playbackTrackUpdate() {
        print("EPPlayerWidgetView: playbackTrackUpdate")
        updateUIForNewTrack()
    }
    
    func trackCachedWithResult(result: Bool) {
        if result {
            self.cacheButton.setTitle("Cached", forState: UIControlState.Normal)
        } else {
            self.cacheButton.setTitle("Save", forState: UIControlState.Normal)
        }
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
        
        self.leftPlaybackTimeLabel.text = "00:00"
        self.rightPlaybackTimeLabel.text = EPMusicPlayer.sharedInstance.activeTrack.duration.timeInSecondsToString()
        
        self.artistLabel.text = EPMusicPlayer.sharedInstance.activeTrack.artist
        self.titleLabel.text = EPMusicPlayer.sharedInstance.activeTrack.title
        
        self.artistLabelBig.text = EPMusicPlayer.sharedInstance.activeTrack.artist
        self.titleLabelBig.text = EPMusicPlayer.sharedInstance.activeTrack.title
        
        self.progressBarPlayback.setProgress(0, animated: false)
        self.progressBarPlaybackBig.setProgress(0, animated: false)

        switch EPMusicPlayer.sharedInstance.activeTrack.isCached {
        case true:
            self.cacheButton.setTitle("Cached", forState: UIControlState.Normal)
            break
        default:
            self.cacheButton.setTitle("Save", forState: UIControlState.Normal)
            break
        }
        
        print("updateUIForNewTrack - complete")
    }

    func setPlaceholderArtworkImage(){
        let image = UIImage(named: "icon_cover_placeholder_1")
        let backgroundBlurredImage = UIImage(named: "background_abstract_1")
        
        UIView.transitionWithView(self.albumArtImageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.albumArtImageView.image = image
            }, completion: nil)
        
        UIView.transitionWithView(self.albumArtImageViewBig, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.albumArtImageViewBig.image = nil
            }, completion: nil)
        
        UIView.transitionWithView(self.backgroundAlbumArtImageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.backgroundAlbumArtImageView.image = backgroundBlurredImage
            }, completion: nil)
    }
    
    func setArtworkImage(var image:UIImage) {
        image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        UIView.transitionWithView(self.albumArtImageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.albumArtImageView.image = image
            }, completion: nil)
        
        UIView.transitionWithView(self.albumArtImageViewBig, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.albumArtImageViewBig.image = image
            }, completion: nil)
        
        UIView.transitionWithView(self.backgroundAlbumArtImageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.backgroundAlbumArtImageView.image = image
            }, completion: nil)
    }
}
