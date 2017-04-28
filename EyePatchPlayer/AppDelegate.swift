//
//  AppDelegate.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Realm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
                
        // API Keys Reading, this should always start first
        EPConstants.loadPlistValues()
        
        //  Fabric this starts as early as possible to allow crash reporting
        Fabric.with([Crashlytics.self])
        
        //  Directories (Structure)
        EPCache.performDirectoriesCheck()
        
        //  Realm Migration
        performMigrationIfNeeded()
        
        //  File Migration
        FileMigration.performMigrationIfNeeded()
        
        //  Shake to Shuffle support
        application.applicationSupportsShakeToEdit = true
        
        //  NavBar appearance tint color
        UINavigationBar.appearance().tintColor = UIView.defaultTintColor()

        //  In 5 seconds, check if any scrobbles pending
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(5 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            EPLastFMScrobbleManager.scrobbleFullQueue()
        })
        
        return true
    }

    func performMigrationIfNeeded() {

        //schema version 2 introduced with EPLastFMScrobble object
        let config = RLMRealmConfiguration.default()
        config.schemaVersion = 2
        config.migrationBlock = {
            (migration: RLMMigration, oldSchemaVersion: UInt64) in
            if oldSchemaVersion < 2 {

            }

        }
        RLMRealmConfiguration.setDefault(config)
        RLMRealm.default()

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        EPLastFMScrobbleManager.scrobbleFullQueue()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        EPCache.cacheStateUponTermination(EPMusicPlayer.sharedInstance.activeTrack, playlist: EPMusicPlayer.sharedInstance.playlist)
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

