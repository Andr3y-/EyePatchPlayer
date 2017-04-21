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
        
        let migrationCompleteValue = UserDefaults.standard.bool(forKey: "FileMigrationComplete")
        
        if !migrationCompleteValue {
            //begin animation
            
            guard let loadingView = showLoadingOverlay() else {
                return
            }
            
            //perform
            if performMigration() {
                //completion set bool
                print("File migration complete")
                UserDefaults.standard.set(true, forKey: "FileMigrationComplete")
            } else {
                print("File migration failed")
            }
            
            UIView.animate(withDuration: 0.2, animations: { 
                loadingView.alpha = 0
                }, completion: { (animationFinished) in
                    loadingView.removeFromSuperview()
            })
        } else {
            print("File migration is not needed")
        }
    }
    
    fileprivate class func performMigration() -> Bool {
        //start animation on UIWindow
        
        var result: Bool = false
        
        let allTrackResults = EPTrack.allObjects()

        for i in 0..<allTrackResults.count {
            
            guard let track = allTrackResults[i] as? EPTrack else {
                return result
            }
            
            let oldTrackPath = (EPCache.downloadDirectory() as NSString).appendingPathComponent("\(track.ID).mp3")
            let oldTrackFileExists = FileManager.default.fileExists(atPath: oldTrackPath)
            
            if oldTrackFileExists {
                //move file to new path
                do {
                    try FileManager.default.moveItem(atPath: oldTrackPath, toPath: EPCache.pathForTrackToSave(track))
                    print("\(track.ID).mp3 -> \(track.uniqueID).mp3")
                } catch {
                    return result
                }
            }
            
            let oldArtworkPath = ((EPCache.downloadDirectory() as NSString).appendingPathComponent("artwork") as NSString).appendingPathComponent("\(track.ID).jpg")
            let oldArtworkFileExists = FileManager.default.fileExists(atPath: oldArtworkPath)
            
            if oldArtworkFileExists {
                //move file to new path
                do {
                    try FileManager.default.moveItem(atPath: oldArtworkPath, toPath: EPCache.pathForTrackArtwork(track))
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
        
        
        guard let trackFiles: FileManager.DirectoryEnumerator = FileManager.default.enumerator(atPath: EPCache.downloadDirectory()) else {
            return
        }
        
        var tracksPathsToDelete: [String] = []
        while let path = trackFiles.nextObject() as? String {
            if !path.contains("_") { // checks the extension
                tracksPathsToDelete.append(path)
            }
        }
        
        print("Bad track files to be deleted:\n\(tracksPathsToDelete)")
        
        for badTrackPath in tracksPathsToDelete {
            do {
                try FileManager.default.removeItem(atPath: (EPCache.downloadDirectory() as NSString).appendingPathComponent(badTrackPath))
                print("Removed: \(badTrackPath)")
            } catch {
                
            }
        }
        
        guard let artworkFiles: FileManager.DirectoryEnumerator = FileManager.default.enumerator(atPath: EPCache.artworkDirectory()) else {
            return
        }
        
        var artworkPathsToDelete: [String] = []
        while let path = artworkFiles.nextObject() as? String {
            if !path.contains("_") { // checks the extension
                artworkPathsToDelete.append(path)
            }
        }
        
        print("Bad artwork files to be deleted:\n\(artworkPathsToDelete)")

        for badArtworkPath in artworkPathsToDelete {
            do {
                try FileManager.default.removeItem(atPath: (EPCache.artworkDirectory() as NSString).appendingPathComponent(badArtworkPath))
                print("Removed: \(badArtworkPath)")
            } catch {
                
            }
        }
        
    }
    
    //MARK: UI Stuff
    
    class func showLoadingOverlay() -> UIView? {
        
        guard let delegate = UIApplication.shared.delegate, let window = delegate.window else {
            return nil
        }
        
        let loadingView = UIView(frame: UIScreen.main.bounds)
        loadingView.backgroundColor = .white
        loadingView.alpha = 0
        
        let loadingViewIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        loadingViewIndicator.startAnimating()
        loadingView.addSubview(loadingViewIndicator)
        
        loadingViewIndicator.center = CGPoint(x: loadingView.bounds.width / 2, y: loadingView.bounds.height / 2)
        
        window?.addSubview(loadingView)
        
        UIView.animate(withDuration: 0.2, animations: {
            loadingView.alpha = 1
        })

        return loadingView
    }
}
