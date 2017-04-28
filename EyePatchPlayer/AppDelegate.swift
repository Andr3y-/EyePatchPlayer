//
//  AppDelegate.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk
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


    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        EPLastFMScrobbleManager.scrobbleFullQueue()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")


        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        EPCache.cacheStateUponTermination(EPMusicPlayer.sharedInstance.activeTrack, playlist: EPMusicPlayer.sharedInstance.playlist)
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        VKSdk.processOpen(url, fromApplication: sourceApplication)
        return true
    }

}

