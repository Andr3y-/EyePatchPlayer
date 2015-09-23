//
//  EPDownloadedViewController.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 15/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit

class EPDownloadedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
    }
    
    func loadData() {
        let cachedTracks = EPTrack.allObjects()
        println("cachedTracks.count = \(cachedTracks.count)")
//        println("\(cachedTracks)")
        for trackRLM in cachedTracks {
            if let track: EPTrack = trackRLM as? EPTrack {
                println("track: \(track.artist) - \(track.title)")
            }
        }
//        if (cachedTracks.count > 0){
//            for i in 0...cachedTracks.count-1 {
//                if let track: EPTrack = cachedTracks[i] as? EPTrack {
//                    println("\(track.artist) - \(track.title)")
//                }
//            }
//        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
