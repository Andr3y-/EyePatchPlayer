
//
//  EPPlayerViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 17/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import AVFoundation

class EPPlayerViewController: UIViewController, EPMusicPlayerDelegate {

    var needsUpdate = true
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var maxTimeLabel: UILabel!
    @IBOutlet weak var shuffleSwitch: UISwitch!
    @IBOutlet weak var cacheButton: UIButton!
    @IBOutlet weak var progressBarPlayback: UIProgressView!
    @IBOutlet weak var progressBarDownload: UIProgressView!
    @IBOutlet weak var albumArtImageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shuffleSwitch.setOn(EPMusicPlayer.sharedInstance.playlist.shuffleOn, animated: false)
        self.becomeFirstResponder()
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
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    //EPMusicPlayerDelegate
    func playbackProgressUpdate(currentTime: Int, bufferedPercent: Double) {
        self.currentTimeLabel.text = timeInSecondsToString(currentTime)
        let playbackPercent = Float(currentTime) / Float(EPMusicPlayer.sharedInstance.activeTrack.duration)
        self.progressBarPlayback.setProgress(playbackPercent, animated: false)
        if (!EPMusicPlayer.sharedInstance.activeTrack.isCached) {
            self.progressBarDownload.setProgress(Float(bufferedPercent), animated: false)
        }
    }
    
    func playbackStatusUpdate(playbackStatus: PlaybackStatus) {
        print("playerViewController: playbackStatusUpdate")
        switch playbackStatus {
        case PlaybackStatus.Play:
            self.playPauseButton.setTitle("Play", forState: UIControlState.Normal)
            
        case PlaybackStatus.Pause:
            self.playPauseButton.setTitle("Pause", forState: UIControlState.Normal)
            
        default:
            self.playPauseButton.setTitle("Pause", forState: UIControlState.Normal)
        }
    }
    
    func playbackTrackUpdate() {
        print("playerViewController: playbackTrackUpdate")
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
    
    func updateUIForNewTrack(){
        if EPMusicPlayer.sharedInstance.activeTrack.artworkImage() == nil {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.albumArtImageView.alpha = 0.0
            })
        } else {
            setArtworkImage(EPMusicPlayer.sharedInstance.activeTrack.artworkImage()!)
        }
        
        self.currentTimeLabel.text = "00:00"
        self.maxTimeLabel.text = timeInSecondsToString(EPMusicPlayer.sharedInstance.activeTrack.duration)
        
        self.artistLabel.text = EPMusicPlayer.sharedInstance.activeTrack.artist;
        self.titleLabel.text = EPMusicPlayer.sharedInstance.activeTrack.title
        
        self.progressBarPlayback.setProgress(0, animated: false)
        
        switch EPMusicPlayer.sharedInstance.activeTrack.isCached {
        case true:
            self.cacheButton.setTitle("Cached", forState: UIControlState.Normal)
            self.progressBarDownload.setProgress(1, animated: false)
            break
        default:
            self.cacheButton.setTitle("Save", forState: UIControlState.Normal)
            self.progressBarDownload.setProgress(0, animated: false)
            break
        }

        print("updateUIForNewTrack - complete")
    }
    
    func setArtworkImage(image:UIImage) {
        UIView.transitionWithView(self.albumArtImageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.albumArtImageView.image = image
        }, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        EPMusicPlayer.sharedInstance.delegate = self
        if (self.needsUpdate){
            updateUIForNewTrack()
            self.needsUpdate = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        EPMusicPlayer.sharedInstance.delegate = EPPlayerWidgetView.sharedInstance
    }
    
    func timeInSecondsToString(timeInSeconds:Int) -> String {
        
        let minutes = (timeInSeconds % 3600 / 60) < 10 ? NSString(format: "0%d", timeInSeconds % 3600 / 60) : NSString(format: "%d", timeInSeconds % 3600 / 60)
        let seconds = (timeInSeconds % 3600 % 60) < 10 ? NSString(format: "0%d", timeInSeconds % 3600 % 60) : NSString(format: "%d", timeInSeconds % 3600 % 60)
        return NSString(format: "%@:%@", minutes, seconds) as String
    }
    
    @IBAction func togglePlayPause(sender: AnyObject) {
        EPMusicPlayer.sharedInstance.togglePlayPause()
    }
    @IBAction func forward(sender: AnyObject) {
        EPMusicPlayer.sharedInstance.playNextSong()
    }
    @IBAction func backward(sender: AnyObject) {
        EPMusicPlayer.sharedInstance.playPrevSong()
    }
    @IBAction func switchChangeValue(sender: UISwitch) {
        EPMusicPlayer.sharedInstance.playlist.shuffleOn = sender.on
    }
}
