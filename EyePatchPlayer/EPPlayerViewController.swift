
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        EPMusicPlayer.sharedInstance.delegate = self
    }
    
    //EPMusicPlayerDelegate
    func playbackProgressUpdate(currentTime: Int, downloadedTime: Int) {
        self.currentTimeLabel.text = timeInSecondsToString(currentTime)
    }
    
    func playbackStatusUpdate(playbackStatus: PlaybackStatus) {
        println("playerViewController: playbackStatusUpdate")
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
        println("playerViewController: playbackTrackUpdate")
        updateUIForNewTrack()
    }
    
    func updateUIForNewTrack(){
        self.currentTimeLabel.text = "00:00"
        self.maxTimeLabel.text = timeInSecondsToString(EPMusicPlayer.sharedInstance.activeTrack.duration)
        
        self.artistLabel.text = EPMusicPlayer.sharedInstance.activeTrack.artist;
        self.titleLabel.text = EPMusicPlayer.sharedInstance.activeTrack.title
        
        println("updateUIForNewTrack - complete")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.needsUpdate){
            updateUIForNewTrack()
            self.needsUpdate = false
        }
    }
    
    func timeInSecondsToString(timeInSeconds:Int) -> String {
        
        let minutes = (timeInSeconds % 3600 / 60) < 10 ? NSString(format: "0%d", timeInSeconds % 3600 / 60) : NSString(format: "%d", timeInSeconds % 3600 / 60)
        let seconds = (timeInSeconds % 3600 % 60) < 10 ? NSString(format: "0%d", timeInSeconds % 3600 % 60) : NSString(format: "%d", timeInSeconds % 3600 % 60)
        return NSString(format: "%@:%@", minutes, seconds) as String
    }
    
    @IBAction func togglePlayPause(sender: AnyObject) {
        EPMusicPlayer.sharedInstance.togglePlayPause()
    }
}
