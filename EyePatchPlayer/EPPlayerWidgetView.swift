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

    var isShown = false

    var topOffsetConstaint: NSLayoutConstraint!

    //widget view
    var playPauseButton: RSPlayPauseButton?
    @IBOutlet weak var playPauseButtonPlaceholder: UIView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var progressBarPlayback: UIProgressView!

    
    @IBOutlet weak var interactionViewMain: UIView!
    @IBOutlet weak var interactionView: UIView!
    @IBOutlet weak var contentViewWidget: UIView!

    //mainView
    @IBOutlet weak var contentViewMain: UIView!
    @IBOutlet weak var playerHeaderView: UIView!
    @IBOutlet weak var albumArtImageViewBig: UIImageView!
    
    
    @IBOutlet weak var progressViewPlaybackBig: EPProgressView!
//    @IBOutlet weak var progressBarPlaybackBig: UIProgressView!
    @IBOutlet weak var leftPlaybackTimeLabel: UILabel!
    @IBOutlet weak var rightPlaybackTimeLabel: UILabel!

    @IBOutlet weak var prevTrackButton: UIButton!
    @IBOutlet weak var nextTrackButton: UIButton!
    var playPauseButtonBig: RSPlayPauseButton?
    @IBOutlet weak var playPauseButtonPlaceholderBig: UIView!
    @IBOutlet weak var artistLabelBig: UILabel!
    @IBOutlet weak var titleLabelBig: UILabel!
//    @IBOutlet weak var shuffleSwitch: UISwitch!
    @IBOutlet weak var cacheButton: UIButton!

    @IBOutlet weak var repeatButtonView: EPRepeatButton!
    @IBOutlet weak var shuffleButtonView: EPShuffleButton!
    @IBOutlet weak var trackDataContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var backgroundAlbumArtImageView: UIImageView!
    @IBOutlet weak var vibrancyContentView: UIView!
    var extrasView: EPExtrasView?

    override func awakeFromNib() {
        super.awakeFromNib()

        if UIScreen.mainScreen().bounds.height == 480 {
            //iPhone 4
            self.trackDataContainerConstraint.constant = -20
            self.controlsViewConstraint.constant = -20
        }

        self.userInteractionEnabled = false

        EPPlayerWidgetView.sharedInstance = self
        EPMusicPlayer.sharedInstance.delegate = self

        EPMusicPlayer.sharedInstance.loadDataFromCache {
            (result) -> Void in
            if result {
                UIView.animateWithDuration(0.15, animations: {
                    () -> Void in
                    self.userInteractionEnabled = true
                })
            }
        }
        self.repeatButtonView.tintColor = UIColor.whiteColor()
        self.shuffleButtonView.tintColor = UIColor.whiteColor()
        setupInteractions()

        print("EPPlayerWidgetView awakeFromNib")

    }

    func setupInteractions() {
        //widget
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "interactionTap:")
        self.interactionView.addGestureRecognizer(tapRecognizer)

        let swipeRecognizerRight = UISwipeGestureRecognizer(target: self, action: "interactionSwipe:")
        swipeRecognizerRight.direction = .Right
        self.interactionView.addGestureRecognizer(swipeRecognizerRight)

        let swipeRecognizerLeft = UISwipeGestureRecognizer(target: self, action: "interactionSwipe:")
        swipeRecognizerLeft.direction = .Left
        self.interactionView.addGestureRecognizer(swipeRecognizerLeft)

        let panGestureUp = UIPanGestureRecognizer(target: self, action: "panGesture:")
        self.interactionView.addGestureRecognizer(panGestureUp)

        //main

        let swipeRecognizerRightMain = UISwipeGestureRecognizer(target: self, action: "interactionSwipe:")
        swipeRecognizerRightMain.direction = .Right
        self.interactionViewMain.addGestureRecognizer(swipeRecognizerRightMain)

        let swipeRecognizerLeftMain = UISwipeGestureRecognizer(target: self, action: "interactionSwipe:")
        swipeRecognizerLeftMain.direction = .Left
        self.interactionViewMain.addGestureRecognizer(swipeRecognizerLeftMain)

        let panGestureDown = UIPanGestureRecognizer(target: self, action: "panGestureMain:")
        self.playerHeaderView.addGestureRecognizer(panGestureDown)

        let longPressRight = UILongPressGestureRecognizer(target: self, action: "seekForwardCommand:")
        longPressRight.minimumPressDuration = 0.7
        self.nextTrackButton.addGestureRecognizer(longPressRight)
        let longPressLeft = UILongPressGestureRecognizer(target: self, action: "seekBackwardCommand:")
        longPressLeft.minimumPressDuration = 0.7
        self.prevTrackButton.addGestureRecognizer(longPressLeft)

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if playPauseButton == nil {
            playPauseButton = RSPlayPauseButton(frame: playPauseButtonPlaceholder.frame)
            playPauseButton?.addTarget(self, action: "playPauseTap:", forControlEvents: UIControlEvents.TouchUpInside)
            self.playPauseButtonPlaceholder.backgroundColor = UIColor.clearColor()
            self.contentViewWidget.addSubview(playPauseButton!)
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
        for view in [leftPlaybackTimeLabel, rightPlaybackTimeLabel, artistLabelBig, titleLabelBig, shuffleButtonView, repeatButtonView, cacheButton] {
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

    func seekForwardCommand(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .Began {
            EPMusicPlayer.sharedInstance.toggleForwardSeek()
        } else if recognizer.state == .Ended {
            EPMusicPlayer.sharedInstance.toggleForwardSeek()
        }
    }

    func seekBackwardCommand(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .Began {
            EPMusicPlayer.sharedInstance.toggleBackwardSeek()
        } else if recognizer.state == .Ended {
            EPMusicPlayer.sharedInstance.toggleBackwardSeek()
        }
    }

    func panGesture(sender: UIPanGestureRecognizer) {
        let window = UIApplication.sharedApplication().keyWindow!
        let location: CGPoint = sender.locationInView(window)
        let translation: CGPoint = sender.translationInView(sender.view)
        //detect horizonal swipe

        let hiddenConst: CGFloat = -60.0
        let shownConst: CGFloat = -window.bounds.size.height

        var newConstantForConstraint = -(window.bounds.height - location.y)
        if newConstantForConstraint > hiddenConst {
            newConstantForConstraint = hiddenConst
        } else if newConstantForConstraint < shownConst {
            newConstantForConstraint = shownConst
        }

        if sender.state != UIGestureRecognizerState.Ended {
            self.contentViewWidget.alpha = 1 - ((newConstantForConstraint - hiddenConst) * (shownConst / (shownConst - hiddenConst)) / shownConst)
            topOffsetConstaint.constant = newConstantForConstraint
        }

        if sender.state == UIGestureRecognizerState.Ended {

            if abs(translation.x) > 3 * abs(translation.y) {
                print("x: \(translation.x)")

                if translation.x > 0 {
                    if EPSettings.isSwipeReverseEnabled() {
                        EPMusicPlayer.sharedInstance.playNextSong()
                    } else {
                        EPMusicPlayer.sharedInstance.playPrevSong()
                    }
                    
                } else {
                    if !EPSettings.isSwipeReverseEnabled() {
                        EPMusicPlayer.sharedInstance.playNextSong()
                    } else {
                        EPMusicPlayer.sharedInstance.playPrevSong()
                    }
                }

                if newConstantForConstraint != -60 {
                    self.topOffsetConstaint.constant = hiddenConst
                    UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        () -> Void in
                        //animate back down
                        self.contentViewWidget.alpha = 1
                        self.layoutIfNeeded()
                    }, completion: {
                        (result: Bool) -> Void in
                        //finished
                    })
                }

                return
            } else {
                print("y: \(translation.y)")
            }


            var finalPoint = (sender.translationInView(window).y + sender.velocityInView(window).y * 1.0)

            if finalPoint < shownConst {
                finalPoint = shownConst
            } else if finalPoint > hiddenConst {
                finalPoint = hiddenConst
            }

            print("final y: \(finalPoint)")

            let duration = min(1.0, NSTimeInterval(abs((finalPoint - newConstantForConstraint) / sender.velocityInView(window).y)))
            print("final move dur: \(duration)")


            if finalPoint < shownConst - shownConst * 0.50 {

                topOffsetConstaint.constant = shownConst

                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

                UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    () -> Void in
                    //animations

                    self.contentViewWidget.alpha = 0
                    self.layoutIfNeeded()

                }, completion: {
                    (result: Bool) -> Void in
                    //completion
                    self.isShown = true
                })

            } else {
                topOffsetConstaint.constant = finalPoint

                UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                    () -> Void in
                    self.contentViewWidget.alpha = 1 - ((finalPoint - hiddenConst) * (shownConst / (shownConst - hiddenConst)) / shownConst)
                    self.layoutIfNeeded()
                }, completion: {
                    (result: Bool) -> Void in
                    self.topOffsetConstaint.constant = hiddenConst
                    UIView.animateWithDuration(duration * 2 / 3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        () -> Void in
                        //animate back down
                        self.contentViewWidget.alpha = 1
                        self.layoutIfNeeded()
                    }, completion: {
                        (result: Bool) -> Void in
                        //finished
                    })
                })
            }
        }

        print("velocity: \(sender.velocityInView(window).y)")
        print("newConstantForConstraint: \(newConstantForConstraint)")

    }

    func panGestureMain(sender: UIPanGestureRecognizer) {
        let window = UIApplication.sharedApplication().keyWindow!
        let location: CGPoint = sender.translationInView(window)

        let hiddenConst: CGFloat = -60.0
        let shownConst: CGFloat = -window.bounds.size.height

        var newConstantForConstraint = -(window.bounds.height - location.y)
        if newConstantForConstraint > hiddenConst {
            newConstantForConstraint = hiddenConst
        } else if newConstantForConstraint < shownConst {
            newConstantForConstraint = shownConst
        }

        if sender.state == UIGestureRecognizerState.Ended {

            var finalPoint = (sender.translationInView(window).y + sender.velocityInView(window).y * 1.0)

            if finalPoint < shownConst {
                finalPoint = shownConst
            } else if finalPoint > hiddenConst {
                finalPoint = hiddenConst
            }

            print("final y: \(finalPoint)")

            let duration = min(1.0, NSTimeInterval(abs((finalPoint - newConstantForConstraint) / sender.velocityInView(window).y)))
            print("final move dur: \(duration)")


            if finalPoint > shownConst - shownConst * 0.50 {

                topOffsetConstaint.constant = hiddenConst

                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)

                UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    () -> Void in
                    //animations

                    self.contentViewWidget.alpha = 1
                    self.layoutIfNeeded()

                }, completion: {
                    (result: Bool) -> Void in
                    //completion
                    self.isShown = false
                })

            } else {

                topOffsetConstaint.constant = finalPoint

                UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                    () -> Void in
                    self.contentViewWidget.alpha = 1 - ((finalPoint - hiddenConst) * (shownConst / (shownConst - hiddenConst)) / shownConst)
                    self.layoutIfNeeded()
                }, completion: {
                    (result: Bool) -> Void in
                    self.topOffsetConstaint.constant = shownConst
                    UIView.animateWithDuration(duration * 2 / 3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        () -> Void in
                        //animate back down
                        self.contentViewWidget.alpha = 0
                        self.layoutIfNeeded()
                    }, completion: {
                        (result: Bool) -> Void in
                        //finished
                    })
                })
            }

        } else {
            self.contentViewWidget.alpha = 1 - ((newConstantForConstraint - hiddenConst) * (shownConst / (shownConst - hiddenConst)) / shownConst)
            topOffsetConstaint.constant = newConstantForConstraint
        }
    }

    func interactionTap(sender: AnyObject) {
        print("interaction: tap")

        if isShown {

        } else {
            self.setPlayerShown(true, animated: true)
        }

    }

    @IBAction func hideButtonTap(sender: UIButton) {
        if isShown {
            self.setPlayerShown(false, animated: true)
        } else {

        }
    }

    @IBAction func moreButtonTap(sender: AnyObject) {
        self.toggleShowMore()
    }

    func toggleShowMore() {
        if let extrasView = self.extrasView {
            print("removing extras")
            UIView.animateWithDuration(0.2, animations: {
                () -> Void in
                extrasView.alpha = 0
            }, completion: {
                (result) -> Void in
                if result {
                    extrasView.removeFromSuperview()
                    self.extrasView = nil
                }
            })

        } else {
            print("showing extras")
            self.extrasView = UIView.loadFromNibNamed("EPExtrasView") as? EPExtrasView

            guard let extrasView = self.extrasView else {
                print("extras view is not loaded")
                return
            }

            extrasView.frame = self.albumArtImageViewBig.frame
            extrasView.translatesAutoresizingMaskIntoConstraints = true
            self.contentViewMain.addSubview(extrasView)
            print("extras:\(extrasView.frame)")
            print("album: \(self.albumArtImageViewBig.frame)")
            //FIXME: Remove later when more modes are added

            extrasView.updateContent(true)
        }
    }

    func interactionSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Left:
            if !EPSettings.isSwipeReverseEnabled() {
                EPMusicPlayer.sharedInstance.playNextSong()
            } else {
                EPMusicPlayer.sharedInstance.playPrevSong()
            }
            print("interaction: swipe Left")

            break

        case UISwipeGestureRecognizerDirection.Right:
            if EPSettings.isSwipeReverseEnabled() {
                EPMusicPlayer.sharedInstance.playNextSong()
            } else {
                EPMusicPlayer.sharedInstance.playPrevSong()
            }
            print("interaction: swipe Right")

            break

        default:

            break
        }
    }

    @IBAction func cacheButtonTap(sender: AnyObject) {
//        switch EPMusicPlayer.sharedInstance.activeTrack.isCached {
//        case true:
////            self.cacheButton.setTitle("Cached", forState: UIControlState.Normal)
//            print("removal requested")
//            break
//        default:
//            EPHTTPManager.downloadTrack(EPMusicPlayer.sharedInstance.activeTrack, completion: {
//                (result, track) -> Void in
//                if result && EPMusicPlayer.sharedInstance.activeTrack.ID == track.ID {
//                    self.trackCachedWithResult(true)
//                } else {
//                    self.trackCachedWithResult(false)
//                }
//
//            }, progressBlock: {
//                (progressValue) -> Void in
//            })
//
////            self.cacheButton.setTitle("Saving", forState: UIControlState.Normal)
//            break
//        }
    }

    @IBAction func repeatTap(sender: AnyObject) {
        self.repeatButtonView.setOn(!self.repeatButtonView.isOn, animated: true)
        EPMusicPlayer.sharedInstance.repeatOn = self.repeatButtonView.isOn
    }

    @IBAction func shuffleTap(sender: AnyObject) {
//        print("shuffle tap")
        self.shuffleButtonView.setOn(!self.shuffleButtonView.isOn, animated: true)
        EPMusicPlayer.sharedInstance.playlist.shuffleOn = self.shuffleButtonView.isOn
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

    func setPlayerShown(value: Bool, animated: Bool) {
        if value {
            if isShown {
                print("showing cancelled, already shown")
                return
            }

            isShown = true
        }

        if !value {
            if !isShown {
                print("hiding cancelled, already hidden")
                return
            }

            isShown = false
        }

        UIApplication.sharedApplication().setStatusBarStyle(value ? UIStatusBarStyle.LightContent : UIStatusBarStyle.Default, animated: true)

        topOffsetConstaint.constant = value ? -(UIApplication.sharedApplication().keyWindow?.bounds.height)! : -self.contentViewWidget.bounds.height

        UIView.animateWithDuration(animated ? 0.15 : 0) {
            () -> Void in
            self.layoutIfNeeded()
            self.contentViewWidget.alpha = value ? 0 : 1
        }
    }

    //EPMusicPlayerDelegate
    func playbackProgressUpdate(currentTime: Int, bufferedPercent: Double) {
        let playbackPercent = Float(currentTime) / Float(EPMusicPlayer.sharedInstance.activeTrack.duration)

        self.leftPlaybackTimeLabel.text = currentTime.timeInSecondsToString()
        var remainingPlaybackTime = (EPMusicPlayer.sharedInstance.activeTrack.duration - currentTime)
        if remainingPlaybackTime < 0 {
            remainingPlaybackTime = 0
        }
        self.rightPlaybackTimeLabel.text = remainingPlaybackTime.timeInSecondsToString()

        self.progressBarPlayback.setProgress(playbackPercent, animated: false)

        self.progressViewPlaybackBig.setProgress(playbackPercent, animated: false)
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
//        if result {
//            self.cacheButton.setTitle("Cached", forState: UIControlState.Normal)
//        } else {
//            self.cacheButton.setTitle("Save", forState: UIControlState.Normal)
//        }
    }

    func trackRetrievedArtworkImage(image: UIImage) {
        print("trackRetrievedArtworkImage")
        setArtworkImage(image)
        UIView.animateWithDuration(0.2, animations: {
            () -> Void in
            self.albumArtImageView.alpha = 1.0
        })
    }

    //UI Updates
    func updateUIForNewTrack() {

        self.userInteractionEnabled = true

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

        self.progressViewPlaybackBig.setProgress(0, animated: false)
        
        if EPMusicPlayer.sharedInstance.playlist.shuffleOn != self.shuffleButtonView.isOn {
            self.shuffleButtonView.setOn((EPMusicPlayer.sharedInstance.playlist.shuffleOn), animated: true)
        }
        
        if EPMusicPlayer.sharedInstance.repeatOn != self.repeatButtonView.isOn {
            self.repeatButtonView.setOn((EPMusicPlayer.sharedInstance.repeatOn), animated: true)
        }

//        switch EPMusicPlayer.sharedInstance.activeTrack.isCached {
//        case true:
//            self.cacheButton.setTitle("Cached", forState: UIControlState.Normal)
//            break
//        default:
//            self.cacheButton.setTitle("Save", forState: UIControlState.Normal)
//            break
//        }
        self.extrasView?.updateContent(false)
        print("updateUIForNewTrack - complete")
    }

    func setPlaceholderArtworkImage() {
        let image = UIImage(named: "icon_cover_placeholder_1")
        let backgroundBlurredImage = UIImage(named: "background_ep_gradient")

        UIView.transitionWithView(self.albumArtImageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            () -> Void in
            self.albumArtImageView.image = image
        }, completion: nil)

        UIView.transitionWithView(self.albumArtImageViewBig, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            () -> Void in
            self.albumArtImageViewBig.image = nil
        }, completion: nil)

        UIView.transitionWithView(self.backgroundAlbumArtImageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            () -> Void in
            self.backgroundAlbumArtImageView.image = backgroundBlurredImage
        }, completion: nil)
    }

    func setArtworkImage(var image: UIImage) {
        image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)

        UIView.transitionWithView(self.albumArtImageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            () -> Void in
            self.albumArtImageView.image = image
        }, completion: nil)

        UIView.transitionWithView(self.albumArtImageViewBig, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            () -> Void in
            self.albumArtImageViewBig.image = image
        }, completion: nil)

        UIView.transitionWithView(self.backgroundAlbumArtImageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            () -> Void in
            self.backgroundAlbumArtImageView.image = image
        }, completion: nil)
    }
    @IBAction func progressViewDidEndDragging(sender: AnyObject) {
        print("end dragging progress")
        EPMusicPlayer.sharedInstance.seekToProgress(self.progressViewPlaybackBig.editingProgress)
    }
}
