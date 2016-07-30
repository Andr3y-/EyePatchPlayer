//
//  FileMigration.swift
//  EyePatchPlayer
//
//  Created by Andrey Staroseltsev on 7/30/16.
//  Copyright © 2016 Apppli. All rights reserved.
//

import UIKit

class FileMigration: AnyObject {
    
    class func performMigrationIfNeeded() {
        
        let migrationCompleteValue = NSUserDefaults.standardUserDefaults().boolForKey("FileMigrationComplete")
        
        if !migrationCompleteValue {
            //begin animation
            
            guard let loadingView = showLoadingOverlay() else {
                return
            }
            
            //perform
            if performMigration() {
                //completion set bool
                print("File migration complete")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FileMigrationComplete")
            } else {
                print("File migration failed")
            }
            
            UIView.animateWithDuration(0.2, animations: { 
                loadingView.alpha = 0
                }, completion: { (animationFinished) in
                    loadingView.removeFromSuperview()
            })
        } else {
            print("File migration is not needed")
        }
    }
    
    private class func performMigration() -> Bool {
        //start animation on UIWindow
        
        var result: Bool = false
        
        let allTrackResults = EPTrack.allObjects()
        
        for trackResult in allTrackResults {
            
            guard let track = trackResult as? EPTrack else {
                return result
            }
            
            let oldTrackPath = (EPCache.downloadDirectory() as NSString).stringByAppendingPathComponent("\(track.ID).mp3")
            let oldTrackFileExists = NSFileManager.defaultManager().fileExistsAtPath(oldTrackPath)
            
            if oldTrackFileExists {
                //move file to new path
                do {
                    try NSFileManager.defaultManager().moveItemAtPath(oldTrackPath, toPath: EPCache.pathForTrackToSave(track))
                    print("\(track.ID).mp3 -> \(track.uniqueID).mp3")
                } catch {
                    return result
                }
            }
            
            let oldArtworkPath = ((EPCache.downloadDirectory() as NSString).stringByAppendingPathComponent("artwork") as NSString).stringByAppendingPathComponent("\(track.ID).jpg")
            let oldArtworkFileExists = NSFileManager.defaultManager().fileExistsAtPath(oldArtworkPath)
            
            if oldArtworkFileExists {
                //move file to new path
                do {
                    try NSFileManager.defaultManager().moveItemAtPath(oldArtworkPath, toPath: EPCache.pathForTrackArtwork(track))
                    print("\(track.ID).jpg -> \(track.uniqueID).jpg")
                } catch {
                    return result
                }
            }

        }
        
        removeBadFiles()
        
        result = true
        
        return result
    }
    
    class func removeBadFiles() {
        
        
        guard let trackFiles: NSDirectoryEnumerator = NSFileManager.defaultManager().enumeratorAtPath(EPCache.downloadDirectory()) else {
            return
        }
        
        var tracksPathsToDelete: [String] = []
        while let path = trackFiles.nextObject() as? String {
            if !path.containsString("_") { // checks the extension
                tracksPathsToDelete.append(path)
            }
        }
        
        print("Bad track files to be deleted:\n\(tracksPathsToDelete)")
        
        for badTrackPath in tracksPathsToDelete {
            do {
                try NSFileManager.defaultManager().removeItemAtPath((EPCache.downloadDirectory() as NSString).stringByAppendingPathComponent(badTrackPath))
                print("Removed: \(badTrackPath)")
            } catch {
                
            }
        }
        
        guard let artworkFiles: NSDirectoryEnumerator = NSFileManager.defaultManager().enumeratorAtPath(EPCache.artworkDirectory()) else {
            return
        }
        
        var artworkPathsToDelete: [String] = []
        while let path = artworkFiles.nextObject() as? String {
            if !path.containsString("_") { // checks the extension
                artworkPathsToDelete.append(path)
            }
        }
        
        print("Bad artwork files to be deleted:\n\(artworkPathsToDelete)")

        for badArtworkPath in artworkPathsToDelete {
            do {
                try NSFileManager.defaultManager().removeItemAtPath((EPCache.artworkDirectory() as NSString).stringByAppendingPathComponent(badArtworkPath))
                print("Removed: \(badArtworkPath)")
            } catch {
                
            }
        }
        
    }
    
    //MARK: UI Stuff
    
    class func showLoadingOverlay() -> UIView? {
        
        guard let delegate = UIApplication.sharedApplication().delegate, window = delegate.window else {
            return nil
        }
        
        let loadingView = UIView(frame: UIScreen.mainScreen().bounds)
        loadingView.backgroundColor = .whiteColor()
        loadingView.alpha = 0
        
        let loadingViewIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        loadingViewIndicator.startAnimating()
        loadingView.addSubview(loadingViewIndicator)
        
        loadingViewIndicator.center = CGPoint(x: loadingView.bounds.width / 2, y: loadingView.bounds.height / 2)
        
        window?.addSubview(loadingView)
        
        UIView.animateWithDuration(0.2, animations: {
            loadingView.alpha = 1
        })

        return loadingView
    }
}
