//
//  EyePatchPlayerTests.swift
//  EyePatchPlayerTests
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import XCTest
@testable import EyePatchPlayer

class EyePatchPlayerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
//    func testTracksSimultaneousDownload() {
//        
//        print("TEST START: testArtworkDownloads")
//        
//        let expectation = self.expectationWithDescription("High Expectation")
//        var downloadedCount = 0
//        
//        let track1 = EPTrack()
//        track1.ID = 10001
//        track1.title = "Doomsday"
//        track1.artist = "Overseer"
//        track1.URLString = "https://cs9-12v4.vk.me/p23/7cd698e2d86458.mp3?extra=gF6RuF5UtD_seowDE_OwR6GrEs_Vu9aoWtodWUlRNH8uCU3FgLzj01puezzvF6SlZtvIbXRjmz9IqgogVBwVAaH8a7Jd"
//        
//        let track2 = EPTrack()
//        track2.ID = 10002
//        track2.title = "Justice for all"
//        track2.artist = "Metallica"
//        track2.URLString = "https://cs9-11v4.vk.me/p8/38e40eb706210f.mp3?extra=NKEsAFFbmcsuMR3EsjLMrIfpNDuk8fGOkvNFQhPwrRwbwuTU9NPb1VKN1Vo_C6EbrF0ePJC5UAcQlqsHTA7hgaBf3J2R"
//        
//        let track3 = EPTrack()
//        track3.ID = 10003
//        track3.title = "Battery"
//        track3.artist = "Metallica"
//        track3.URLString = "https://psv4.vk.me/c4869/u13205139/audios/7c150d568ca8.mp3?extra=IkstbH3a4kTMHx7oPuFsjPQu-yp77aITpvA048tvWeH9FAt2R6ZaSfOG8X2zPukjo3VvFvBD_VjWD0kwM1YpPgB_ujdh"
//        
//        let track4 = EPTrack()
//        track4.ID = 10004
//        track4.title = "He Got Game"
//        track4.artist = "Public Enemy"
//        track4.URLString = "https://cs9-15v4.vk.me/p16/35960990ab984a.mp3?extra=CsNBgr26r19Btp9XwszUFU8zaLbnCtTmMZT1gW8pxnikhdMqOqJFt3U7dfME3yIutyKC2CyyraNHfvKxI_Cr5XDq-eac"
//
//        self.deleteTestTracks([track1,track2,track3,track4])
//
//        for track in [track1,track2,track3,track4] {
//            EPHTTPManager.downloadTrack(track, completion: { (result, track) -> Void in
//                if result {
//                    print("test track finished downloading")
//                }
//                }, progressBlock: { (progressValue) -> Void in
//                    if progressValue > 0 {
//                        print("\(track.title) - progress = \(progressValue)")
//                    }
//            })
//        }
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
//            if (downloadedCount == 1) {
//                print("TEST: One Image has been downloaded")
//                expectation.fulfill()
//            }
//        })
//        
//        self.waitForExpectationsWithTimeout(100.0) { (error) -> Void in
//            
//        }
//    }
//    
//    func deleteTestTracks(tracks: [EPTrack]) {
//        for track in tracks {
//            if !EPCache.deleteTrackFromDownload(track) {
////                XCTAssert(false, "failed to remove testing track")
//            }
//        }
//    }
    
    func testMessagesParsing() {
        
        let expectation = self.expectationWithDescription("testMessagesParsing Expectation")
        
        var parsedTracks = [EPTrack]()
//        var parsedTracksFinal = [EPTrack]()
        
        EPHTTPManager.VKGetLastAudiosFromMessages(10, intermediateResultBlock: { (track) -> Void in
            print(track.ID)
            parsedTracks.append(track)
            
            }) { (result, tracks) -> Void in
                
                if tracks?.count == 10 && tracks != nil {
                    expectation.fulfill()
                } else {
                    XCTAssert(false, "failed no tracks parsed")
                }
        }
        
        self.waitForExpectationsWithTimeout(30) { (error) -> Void in
            
        }
    }
    
//    func testArtworkDownloads() {
//
//        print("TEST START: testArtworkDownloads")
//        
//        let expectation = self.expectationWithDescription("High Expectation")
//        var downloadedCount = 0
//        
//        let track1 = EPTrack()
//        track1.title = "The Day That Never Comes"
//        track1.artist = "Metallica"
//        
//        let track2 = EPTrack()
//        track2.title = "Justice for all"
//        track2.artist = "Metallica"
//    
//        let track3 = EPTrack()
//        track3.title = "Hero of the Day"
//        track3.artist = "Metallica"
//    
//        let track4 = EPTrack()
//        track4.title = "Master of Puppets"
//        track4.artist = "Metallica"
//        
//        for track in [track1,track2,track3,track4] {
//            EPHTTPManager.getAlbumCoverImage(track) { (result, image, trackID) -> Void in
//                print("\(track.title) - finished download:")
//                if result {
//                    downloadedCount++
//                    print("OK")
//                } else {
//                    print("NOT OK")
//                }
//            }
//        }
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
//            if (downloadedCount == 1) {
//                print("TEST: One Image has been downloaded")
//                expectation.fulfill()
//            }
//        })
//        
//        self.waitForExpectationsWithTimeout(6.0) { (error) -> Void in
//            
//        }
//    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
