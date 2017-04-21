//
//  EPTrackTableViewCell.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 09/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPTrackTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressIndicatorView: EPStatusIndicatorView!
    var downloadProgress: EPDownloadProgress?
    var track: EPTrack!
    @IBOutlet weak var mainTapArea: UIView!
    @IBOutlet weak var secondaryTapArea: UIView!
    @IBOutlet weak var constraintSelectionIndicator: NSLayoutConstraint!
    @IBOutlet weak var selectionIndicatorView: UIView!
    weak var delegate: EPTrackTableViewCellDelegate?

    override func prepareForReuse() {
        super.prepareForReuse()

        self.progressIndicatorView.clear()

//        self.progressIndicatorView.animateRotation(false)
//        self.progressIndicatorView.setStatusComplete(false, animated: false)
//        self.progressIndicatorView.progress = 1

        if (self.track != nil) {
            self.track.removeObserver(self, forKeyPath: "downloadProgress")
        }

        if downloadProgress != nil {
            self.downloadProgress?.removeObserver(self, forKeyPath: "percentComplete")
            self.downloadProgress?.removeObserver(self, forKeyPath: "finished")
        }

        self.downloadProgress = nil

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionIndicatorView.backgroundColor = UIView.defaultTintColor()
        self.selectionStyle = UITableViewCellSelectionStyle.none
        let primaryTapper = UITapGestureRecognizer(target: self, action: #selector(mainTap))
        self.mainTapArea.addGestureRecognizer(primaryTapper)
        self.durationLabel.font = self.durationLabel.font.monospacedDigitFont
        let secondaryTapper = UITapGestureRecognizer(target: self, action: #selector(secondaryTap))
        self.secondaryTapArea.addGestureRecognizer(secondaryTapper)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        constraintSelectionIndicator.constant = selected ? 0 : -4
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                () -> Void in
                self.contentView.layoutIfNeeded()
            }) 
        }
    }

    deinit {
        if (self.track != nil) {
            self.track.removeObserver(self, forKeyPath: "downloadProgress")
        }

        if downloadProgress != nil {
            self.downloadProgress?.removeObserver(self, forKeyPath: "percentComplete")
            self.downloadProgress?.removeObserver(self, forKeyPath: "finished")
        }

        self.downloadProgress = nil
    }

    func mainTap(_ sender: AnyObject) {
        self.delegate?.cellDetectedPrimaryTap(self)
    }

    func secondaryTap(_ sender: AnyObject) {
        self.delegate?.cellDetectedSecondaryTap(self)
    }

    func setupDownloadProgress(_ downloadProgress: EPDownloadProgress) {
        print("setupDownloadProgress")

        if self.downloadProgress != nil {
            self.downloadProgress?.removeObserver(self, forKeyPath: "percentComplete")
            self.downloadProgress?.removeObserver(self, forKeyPath: "finished")
        }

        self.downloadProgress = downloadProgress
        self.progressIndicatorView.progress = CGFloat(downloadProgress.percentComplete)
        self.progressIndicatorView.animateRotation(true)

        self.downloadProgress!.addObserver(self, forKeyPath: "percentComplete", options: [.new, .old], context: nil)
        self.downloadProgress!.addObserver(self, forKeyPath: "finished", options: [.new, .old], context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey:Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "percentComplete" {

            if let newProgress = object as? EPDownloadProgress {
//                print("cellForTrack: \(self.titleLabel!.text) | progress update: \(newProgress)")
                self.progressIndicatorView.progress = CGFloat(newProgress.percentComplete)
            }
        } else if keyPath == "finished" {

            if let newProgress = object as? EPDownloadProgress {
                print("progress finished: \(newProgress.finished)")
                if newProgress.finished {
//                    self.downloadProgress?.removeObserver(self, forKeyPath: "percentComplete")
//                    self.downloadProgress?.removeObserver(self, forKeyPath: "finished")
                    
                    self.progressIndicatorView.animateCompletion()
                } else {
                    self.progressIndicatorView.animateCancellation()
                    self.progressIndicatorView.setStatusComplete(false, animated: false)
                }
            }

        } else if keyPath == "downloadProgress" {
            print("cell detected new download progress")
            let track = object as! EPTrack
            if let downloadProgress = track.downloadProgress {
                self.setupDownloadProgress(downloadProgress)

            }
        }
    }

    func setupLayoutForTrack(_ track: EPTrack) {

        self.track = track

        if track.isCached {
            //            self.statusImageView.image = UIImage(named: "icon_tick")
            progressIndicatorView.setStatusComplete(true, animated: false)

        } else {
            //            self.statusImageView.image = UIImage(named: "icon_cross")
            progressIndicatorView.setStatusComplete(false, animated: false)
        }

        self.track.addObserver(self, forKeyPath: "downloadProgress", options: [.new, .old], context: nil)

    }

    func setCacheStatus(_ status: Bool) {
        if status {
//            self.statusImageView.image = UIImage(named: "icon_tick")
            progressIndicatorView.setStatusComplete(true, animated: false)

        } else {
//            self.statusImageView.image = UIImage(named: "icon_cross")
            progressIndicatorView.setStatusComplete(false, animated: false)
        }
    }
}
