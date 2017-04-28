//
//  EPPlayerWidgetView.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import EPPUIKit

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

    @IBOutlet weak var leftPlaybackTimeLabel: UILabel!
    @IBOutlet weak var rightPlaybackTimeLabel: UILabel!

    @IBOutlet weak var prevTrackButton: UIButton!
    @IBOutlet weak var nextTrackButton: UIButton!
    var playPauseButtonBig: RSPlayPauseButton?
    @IBOutlet weak var playPauseButtonPlaceholderBig: UIView!
    @IBOutlet weak var artistLabelBig: UILabel!
    @IBOutlet weak var titleLabelBig: UILabel!

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

        if UIScreen.main.bounds.height == 480 {
            //iPhone 4
            self.trackDataContainerConstraint.constant = -20
            self.controlsViewConstraint.constant = -20
        }
        self.progressBarPlayback.progressTintColor = UIView.defaultTintColor()
        self.isUserInteractionEnabled = false

        EPPlayerWidgetView.sharedInstance = self
        EPMusicPlayer.sharedInstance.delegate = self

        EPMusicPlayer.sharedInstance.loadDataFromCache {
            (result) -> Void in
            if result {
                UIView.animate(withDuration: 0.15, animations: {
                    () -> Void in
                    self.isUserInteractionEnabled = true
                })
            }
        }
        self.repeatButtonView.tintColor = UIColor.white
        self.shuffleButtonView.tintColor = UIColor.white
        setupInteractions()
        
        NotificationCenter.default.addObserver(self, selector: #selector(EPPlayerWidgetView.handleLogout), name: NSNotification.Name(rawValue: "LogoutComplete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EPPlayerWidgetView.handleLogin), name: NSNotification.Name(rawValue: "LoginComplete"), object: nil)

    }

    func setupInteractions() {
        //widget
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(EPPlayerWidgetView.interactionTap(_:)))
        self.interactionView.addGestureRecognizer(tapRecognizer)

        let swipeRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(EPPlayerWidgetView.interactionSwipe(_:)))
        swipeRecognizerRight.direction = .right
        self.interactionView.addGestureRecognizer(swipeRecognizerRight)

        let swipeRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(EPPlayerWidgetView.interactionSwipe(_:)))
        swipeRecognizerLeft.direction = .left
        self.interactionView.addGestureRecognizer(swipeRecognizerLeft)

        let panGestureUp = UIPanGestureRecognizer(target: self, action: #selector(EPPlayerWidgetView.panGesture(_:)))
        self.interactionView.addGestureRecognizer(panGestureUp)

        //main

        let swipeRecognizerRightMain = UISwipeGestureRecognizer(target: self, action: #selector(EPPlayerWidgetView.interactionSwipe(_:)))
        swipeRecognizerRightMain.direction = .right
        self.interactionViewMain.addGestureRecognizer(swipeRecognizerRightMain)

        let swipeRecognizerLeftMain = UISwipeGestureRecognizer(target: self, action: #selector(EPPlayerWidgetView.interactionSwipe(_:)))
        swipeRecognizerLeftMain.direction = .left
        self.interactionViewMain.addGestureRecognizer(swipeRecognizerLeftMain)

        let panGestureDown = UIPanGestureRecognizer(target: self, action: #selector(EPPlayerWidgetView.panGestureMain(_:)))
        self.playerHeaderView.addGestureRecognizer(panGestureDown)

        let longPressRight = UILongPressGestureRecognizer(target: self, action: #selector(EPPlayerWidgetView.seekForwardCommand(_:)))
        longPressRight.minimumPressDuration = 0.7
        self.nextTrackButton.addGestureRecognizer(longPressRight)
        let longPressLeft = UILongPressGestureRecognizer(target: self, action: #selector(EPPlayerWidgetView.seekBackwardCommand(_:)))
        longPressLeft.minimumPressDuration = 0.7
        self.prevTrackButton.addGestureRecognizer(longPressLeft)

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if playPauseButton == nil {
            playPauseButton = RSPlayPauseButton(frame: playPauseButtonPlaceholder.frame)
            playPauseButton?.tintColor = UIView.defaultTintColor()
            playPauseButton?.addTarget(self, action: #selector(EPPlayerWidgetView.playPauseTap(_:)), for: UIControlEvents.touchUpInside)
            self.playPauseButtonPlaceholder.backgroundColor = UIColor.clear
            self.contentViewWidget.addSubview(playPauseButton!)
        }

        if playPauseButtonBig == nil {
            playPauseButtonBig = RSPlayPauseButton(frame: playPauseButtonPlaceholderBig.frame)
            playPauseButtonBig?.addTarget(self, action: #selector(EPPlayerWidgetView.playPauseTap(_:)), for: UIControlEvents.touchUpInside)
            self.playPauseButtonPlaceholderBig.backgroundColor = UIColor.clear
            self.vibrancyContentView.addSubview(playPauseButtonBig!)
        }
        self.playPauseButtonBig?.frame.origin = self.playPauseButtonPlaceholderBig.frame.origin
        self.playPauseButton?.frame.origin = self.playPauseButtonPlaceholder.frame.origin

    }

    func processViews() {
        for view in [leftPlaybackTimeLabel, rightPlaybackTimeLabel, artistLabelBig, titleLabelBig, shuffleButtonView, repeatButtonView] as [UIView] {
            if (view as AnyObject).superview! != self.vibrancyContentView {

                let newRect = view.convert(view.bounds, to: self.vibrancyContentView)

                view.removeConstraints(view.constraints)

                self.vibrancyContentView.addSubview(view)
                view.frame = newRect
            }
        }
    }

    //Interactions

    func seekForwardCommand(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            EPMusicPlayer.sharedInstance.toggleForwardSeek()
        } else if recognizer.state == .ended {
            EPMusicPlayer.sharedInstance.toggleForwardSeek()
        }
    }

    func seekBackwardCommand(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            EPMusicPlayer.sharedInstance.toggleBackwardSeek()
        } else if recognizer.state == .ended {
            EPMusicPlayer.sharedInstance.toggleBackwardSeek()
        }
    }

    func panGesture(_ sender: UIPanGestureRecognizer) {
        let window = UIApplication.shared.keyWindow!
        let location: CGPoint = sender.location(in: window)
        let translation: CGPoint = sender.translation(in: sender.view)
        //detect horizonal swipe

        let hiddenConst: CGFloat = -60.0
        let shownConst: CGFloat = -window.bounds.size.height

        var newConstantForConstraint = -(window.bounds.height - location.y)
        if newConstantForConstraint > hiddenConst {
            newConstantForConstraint = hiddenConst
        } else if newConstantForConstraint < shownConst {
            newConstantForConstraint = shownConst
        }

        if sender.state != UIGestureRecognizerState.ended {
            self.contentViewWidget.alpha = 1 - ((newConstantForConstraint - hiddenConst) * (shownConst / (shownConst - hiddenConst)) / shownConst)
            topOffsetConstaint.constant = newConstantForConstraint
        }

        if sender.state == UIGestureRecognizerState.ended {

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
                    UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(), animations: {
                        () -> Void in
                        //animate back down
                        self.contentViewWidget.alpha = 1
                        self.superview?.layoutIfNeeded()
                    }, completion: {
                        (result: Bool) -> Void in
                        //finished
                    })
                }

                return
            } else {
                print("y: \(translation.y)")
            }


            var finalPoint = (sender.translation(in: window).y + sender.velocity(in: window).y * 1.0)

            if finalPoint < shownConst {
                finalPoint = shownConst
            } else if finalPoint > hiddenConst {
                finalPoint = hiddenConst
            }

            print("final y: \(finalPoint)")

            let duration = min(1.0, TimeInterval(abs((finalPoint - newConstantForConstraint) / sender.velocity(in: window).y)))
            print("final move dur: \(duration)")


            if finalPoint < shownConst - shownConst * 0.50 {

                topOffsetConstaint.constant = shownConst

                UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
                
                UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    () -> Void in
                    //animations

                    self.contentViewWidget.alpha = 0
                    self.superview?.layoutIfNeeded()

                }, completion: {
                    (result: Bool) -> Void in
                    //completion
                    self.isShown = true
                })

            } else {
                topOffsetConstaint.constant = finalPoint

                UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                    () -> Void in
                    self.contentViewWidget.alpha = 1 - ((finalPoint - hiddenConst) * (shownConst / (shownConst - hiddenConst)) / shownConst)
                    self.superview?.layoutIfNeeded()
                }, completion: {
                    (result: Bool) -> Void in
                    self.topOffsetConstaint.constant = hiddenConst
                    UIView.animate(withDuration: duration * 2 / 3, delay: 0, options: UIViewAnimationOptions(), animations: {
                        () -> Void in
                        //animate back down
                        self.contentViewWidget.alpha = 1
                        self.superview?.layoutIfNeeded()
                    }, completion: {
                        (result: Bool) -> Void in
                        //finished
                    })
                })
            }
        }
    }

    func panGestureMain(_ sender: UIPanGestureRecognizer) {
        let window = UIApplication.shared.keyWindow!
        let location: CGPoint = sender.translation(in: window)

        let hiddenConst: CGFloat = -60.0
        let shownConst: CGFloat = -window.bounds.size.height

        var newConstantForConstraint = -(window.bounds.height - location.y)
        if newConstantForConstraint > hiddenConst {
            newConstantForConstraint = hiddenConst
        } else if newConstantForConstraint < shownConst {
            newConstantForConstraint = shownConst
        }

        if sender.state == UIGestureRecognizerState.ended {

            var finalPoint = (sender.translation(in: window).y + sender.velocity(in: window).y * 1.0)

            if finalPoint < shownConst {
                finalPoint = shownConst
            } else if finalPoint > hiddenConst {
                finalPoint = hiddenConst
            }

            print("final y: \(finalPoint)")

            let duration = min(1.0, TimeInterval(abs((finalPoint - newConstantForConstraint) / sender.velocity(in: window).y)))
            print("final move dur: \(duration)")


            if finalPoint > shownConst - shownConst * 0.50 {

                topOffsetConstaint.constant = hiddenConst

                UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)

                UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    () -> Void in
                    //animations

                    self.contentViewWidget.alpha = 1
                    self.superview?.layoutIfNeeded()

                }, completion: {
                    (result: Bool) -> Void in
                    //completion
                    self.isShown = false
                })

            } else {

                topOffsetConstaint.constant = finalPoint

                UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                    () -> Void in
                    self.contentViewWidget.alpha = 1 - ((finalPoint - hiddenConst) * (shownConst / (shownConst - hiddenConst)) / shownConst)
                    self.superview?.layoutIfNeeded()
                }, completion: {
                    (result: Bool) -> Void in
                    self.topOffsetConstaint.constant = shownConst
                    UIView.animate(withDuration: duration * 2 / 3, delay: 0, options: UIViewAnimationOptions(), animations: {
                        () -> Void in
                        //animate back down
                        self.contentViewWidget.alpha = 0
                        self.superview?.layoutIfNeeded()
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

    func interactionTap(_ sender: AnyObject) {
        print("interaction: tap")

        if isShown {

        } else {
            self.setPlayerShown(true, animated: true)
        }

    }

    @IBAction func hideButtonTap(_ sender: UIButton) {
        if isShown {
            self.setPlayerShown(false, animated: true)
        } else {

        }
    }

    @IBAction func moreButtonTap(_ sender: AnyObject) {
        self.toggleShowMore()
    }

    func toggleShowMore() {
        if let extrasView = self.extrasView {
            print("removing extras")
            UIView.animate(withDuration: 0.2, animations: {
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

    func interactionSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.left:
            if !EPSettings.isSwipeReverseEnabled() {
                EPMusicPlayer.sharedInstance.playNextSong()
            } else {
                EPMusicPlayer.sharedInstance.playPrevSong()
            }
            print("interaction: swipe Left")

            break

        case UISwipeGestureRecognizerDirection.right:
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

    @IBAction func repeatTap(_ sender: AnyObject) {
        self.repeatButtonView.setOn(!self.repeatButtonView.isOn, animated: true)
        EPMusicPlayer.sharedInstance.repeatOn = self.repeatButtonView.isOn
    }

    @IBAction func shuffleTap(_ sender: AnyObject) {
        self.shuffleButtonView.setOn(!self.shuffleButtonView.isOn, animated: true)
        EPMusicPlayer.sharedInstance.playlist.shuffleOn = self.shuffleButtonView.isOn
    }
    
    func playPauseTap(_ button: RSPlayPauseButton) {
        EPMusicPlayer.sharedInstance.togglePlayPause()
    }

    @IBAction func nextTrackTap(_ sender: AnyObject) {
        EPMusicPlayer.sharedInstance.playNextSong()
    }

    @IBAction func prevTrackTap(_ sender: AnyObject) {
        EPMusicPlayer.sharedInstance.playPrevSong()
    }

    func setPlayerShown(_ value: Bool, animated: Bool) {
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

        UIApplication.shared.setStatusBarStyle(value ? UIStatusBarStyle.lightContent : UIStatusBarStyle.default, animated: true)

        topOffsetConstaint.constant = value ? -(UIApplication.shared.keyWindow?.bounds.height)! : -self.contentViewWidget.bounds.height

        UIView.animate(withDuration: animated ? 0.15 : 0, animations: {
            () -> Void in
            self.superview?.layoutIfNeeded()
            self.contentViewWidget.alpha = value ? 0 : 1
        }) 
    }

    //EPMusicPlayerDelegate
    func playbackProgressUpdate(_ currentTime: Int, bufferedPercent: Double) {
        let playbackPercent = Float(currentTime) / Float(EPMusicPlayer.sharedInstance.activeTrack.duration)

        self.leftPlaybackTimeLabel.text = currentTime.durationString
        var remainingPlaybackTime = (EPMusicPlayer.sharedInstance.activeTrack.duration - currentTime)
        if remainingPlaybackTime < 0 {
            remainingPlaybackTime = 0
        }
        self.rightPlaybackTimeLabel.text = remainingPlaybackTime.durationString

        self.progressBarPlayback.setProgress(playbackPercent, animated: false)

        self.progressViewPlaybackBig.setProgress(playbackPercent, animated: false)
    }

    func playbackStatusUpdate(_ playbackStatus: PlaybackStatus) {
        print("EPPlayerWidgetView: playbackStatusUpdate: \(playbackStatus)")
        switch playbackStatus {
        case PlaybackStatus.play:
            self.playPauseButton?.setPaused(false, animated: true)
            self.playPauseButtonBig?.setPaused(false, animated: true)

        case PlaybackStatus.pause:
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

    func trackRetrievedArtworkImage(_ image: UIImage) {
        print("trackRetrievedArtworkImage")
        setArtworkImage(image)
        UIView.animate(withDuration: 0.2, animations: {
            () -> Void in
            self.albumArtImageView.alpha = 1.0
        })
    }

    //UI Updates
    func updateUIForNewTrack() {

        self.isUserInteractionEnabled = true

        if EPMusicPlayer.sharedInstance.activeTrack.artworkImage() == nil {
            setPlaceholderArtworkImage()
        } else {
            setArtworkImage(EPMusicPlayer.sharedInstance.activeTrack.artworkImage()!)
        }

        self.leftPlaybackTimeLabel.text = "00:00"
        self.rightPlaybackTimeLabel.text = EPMusicPlayer.sharedInstance.activeTrack.duration.durationString

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

        self.extrasView?.updateContent(false)
        print("updateUIForNewTrack - complete")
    }

    func setPlaceholderArtworkImage() {
        let image = UIImage(named: "icon_cover_placeholder_1")
        let backgroundBlurredImage = UIImage(named: "background_ep_gradient")

        UIView.transition(with: self.albumArtImageView, duration: 0.2, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            () -> Void in
            self.albumArtImageView.image = image
        }, completion: nil)

        UIView.transition(with: self.albumArtImageViewBig, duration: 0.2, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            () -> Void in
            self.albumArtImageViewBig.image = nil
        }, completion: nil)

        UIView.transition(with: self.backgroundAlbumArtImageView, duration: 0.2, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            () -> Void in
            self.backgroundAlbumArtImageView.image = backgroundBlurredImage
        }, completion: nil)
    }

    func setArtworkImage(_ image: UIImage) {
        var image = image
        image = image.withRenderingMode(UIImageRenderingMode.alwaysOriginal)

        UIView.transition(with: self.albumArtImageView, duration: 0.2, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            () -> Void in
            self.albumArtImageView.image = image
        }, completion: nil)

        UIView.transition(with: self.albumArtImageViewBig, duration: 0.2, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            () -> Void in
            self.albumArtImageViewBig.image = image
        }, completion: nil)

        UIView.transition(with: self.backgroundAlbumArtImageView, duration: 0.2, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            () -> Void in
            self.backgroundAlbumArtImageView.image = image
        }, completion: nil)
    }
    
    @IBAction func progressViewDidEndDragging(_ sender: AnyObject) {
        print("end dragging progress")
        EPMusicPlayer.sharedInstance.seekToProgress(self.progressViewPlaybackBig.editingProgress)
    }
    
    //  Logout / Login Handlers
    
    func handleLogout() {
        self.isHidden = true
        self.isUserInteractionEnabled = false
    }
    
    func handleLogin() {
        self.isHidden = false
        self.isUserInteractionEnabled = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
