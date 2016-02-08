
//
//  AppDelegate.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import VK_ios_sdk
import AFNetworking
import Fabric
import Crashlytics
import Realm
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        
        //  Realm Migration
        performMigrationIfNeeded()
        //  Directories (Structure)
        EPCache.performStartChecks()
        
        //  Fabric
        Fabric.with([Crashlytics.self])
        
        //  Reachability
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        
        //  Parse
        Parse.setApplicationId(EPConstantsClass.ParseAppID,
            clientKey: EPConstantsClass.ParseKey)
        
        //  [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        //  Shake to Shuffle support
        application.applicationSupportsShakeToEdit = true
        
        //  NavBar appearance tint color
        UINavigationBar.appearance().tintColor = UIView.defaultTintColor()

        //  In 5 seconds, check if any scrobbles pending
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            EPLastFMScrobbleManager.scrobbleFullQueue()
        })
        
        return true
    }

    func performMigrationIfNeeded() {

        //schema version 2 introduced with EPLastFMScrobble object
        let config = RLMRealmConfiguration.defaultConfiguration()
        config.schemaVersion = 2
        config.migrationBlock = {
            (migration: RLMMigration, oldSchemaVersion: UInt64) in
            if oldSchemaVersion < 2 {

            }

        }
        RLMRealmConfiguration.setDefaultConfiguration(config)
        RLMRealm.defaultRealm()

    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        print("applicationDidEnterBackground")
        EPLastFMScrobbleManager.scrobbleFullQueue()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        print("applicationDidBecomeActive")


        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        EPCache.cacheStateUponTermination(EPMusicPlayer.sharedInstance.activeTrack, playlist: EPMusicPlayer.sharedInstance.playlist)
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        VKSdk.processOpenURL(url, fromApplication: sourceApplication)
        return true
    }

}

