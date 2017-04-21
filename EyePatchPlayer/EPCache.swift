//
//  EPCache.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 18/09/2015.
//  Copyright (c) 2015 Apppli. All rights reserved.
//

import UIKit
import Realm

protocol EPCacheDelegate: class {
    func cacheDidUpdate()
}

class EPCache: NSObject {

    static func addTrackToDownloadWithFileAtPath(_ track: EPTrack, filePath: String) -> (Bool) {
        var result: Bool = false

        //check if already exists
        if checkTrackFileExistsInDownload(track) {
            //file already exists, handling

            let existingObjects = EPTrack.objects(with: NSPredicate(format: "ID = %d", track.ID))

            if (existingObjects.count == 0) {
                //we're good to go

            } else if (existingObjects.count == 1) {
                //object already cached and is contained now in existing objects
                //handle? perhaps, replace track with retrieved cached instance and return true

                return false
            } else {
                //existing objects count is neither 0 nor 1
                return false
            }

        }

        //if doesn't move file from old path to new path and record a result
        var error: NSError?
        let newPath: String = pathForTrackToSave(track)

        if newPath != filePath {

            //file needs to be moved to a right folder
            let moveResult: Bool
            do {
                try FileManager.default.moveItem(atPath: filePath, toPath: newPath)
                moveResult = true
            } catch let error1 as NSError {
                error = error1
                moveResult = false
            }

            if moveResult {

                //move was successful, file now exists at newPath

            } else {

                //move was unsuccessful, file doesn't exist at newPath, access error for more details

                if let unwrappedError = error {

                    print("addTrackToCacheWithFileAtPath\nmoving file failed, error:\n\(unwrappedError.description)")

                    return false
                }
            }
        }
        //create a new one now

        track.isCached = true
        track.URLString = newPath
        if let artworkToSave = track.artworkUIImage {
            print("artwork downloaded, trying to add to cache too")
            track.addArtworkImage(artworkToSave)
        } else {
            print("artwork is missing trying to download")
            EPHTTPTrackMetadataManager.getAlbumCoverImage(track, completion: {
                (result, image, trackID) -> Void in
                if result {
                    track.addArtworkImage(image)
                }
            })
        }
        
        if track.observationInfo != nil {
            print("track observation info is non-nil, however addOrUpdateObject is called")
            if let trackCopy = track.copy() as? EPTrack {
                do {
                    RLMRealm.default().beginWriteTransaction()
                    RLMRealm.default().addOrUpdate(trackCopy)
                    try RLMRealm.default().commitWriteTransaction()
                } catch {

                }

            }
        } else {
            do {
                RLMRealm.default().beginWriteTransaction()
                RLMRealm.default().addOrUpdate(track)
                try RLMRealm.default().commitWriteTransaction()
            } catch {

            }

        }
        
        result = true
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TrackCached"), object: track)
        print("added track to storage")

        return result
    }

    static func addTrackToDownloadWithFileData(_ track: EPTrack, data: Data) -> (Bool) {
        let result: Bool = false

        //check if already exists,

        return result
    }

    static func deleteTrackFromDownload(_ track: EPTrack) -> (Bool) {
        var result: Bool

        NotificationCenter.default.post(name: Notification.Name(rawValue: "Track.Delete"), object: nil, userInfo: ["track": track])

        do {
            try FileManager.default.removeItem(atPath: pathForTrackToSave(track))
            result = true
        } catch _ {
            result = false
        }
//        var result2: Bool
        do {
            try FileManager.default.removeItem(atPath: pathForTrackArtwork(track))
//            result2 = true
        } catch _ {
//            result2 = false
        }

        if let _ = trackCachedInstanceForTrack(track) {

            do {
                RLMRealm.default().beginWriteTransaction()
                RLMRealm.default().delete(track)
                try RLMRealm.default().commitWriteTransaction()
                
            } catch {
                
            }

        }

        return result
        //check if already exists,
    }

    static func trackCachedInstanceForTrack(_ track: EPTrack) -> (EPTrack)? {
        let existingObjects = EPTrack.objects(with: NSPredicate(format: "ID = %d", track.ID))
//        println("existingObjects: \(existingObjects)")
        if (existingObjects.count == 0) {
            return nil

        } else if (existingObjects.count == 1) {
            //object already cached and is contained now in existing objects
            //handle? perhaps, replace track with retrieved cached instance and return true
            let trackRLM: RLMObject? = existingObjects.firstObject()
            if let track: EPTrack = trackRLM as? EPTrack {
                print("trackCachedInstanceForTrack: \(track.artist) - \(track.title)\nlocated at: \(track.URL())")
                return track
            } else {
                return nil
            }

        } else {
            print("non unique result")
            return nil
        }
    }

//    static var cacheRetrievalExecutionTime:CFAbsoluteTime = 0

    static func cacheStatusForTrack(_ track: EPTrack) -> (Bool) {

        let existingObjects = EPTrack.objects(with: NSPredicate(format: "(ID = %d) AND (ownerID = %d)", track.ID, track.ownerID))

        if (existingObjects.count == 0) {
            return false
        } else {
            return true
        }
    }

    static func downloadDirectory() -> (String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        return documentsPath.appendingPathComponent("download")
    }

    class func artworkDirectory() -> (String) {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        return documentsPath.appendingPathComponent("artwork")
    }
    static func cacheDirectory() -> (String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        return documentsPath.appendingPathComponent("cache")
    }

    static func cacheEnabled() -> (Bool) {
        return true
    }

    static func maxDiskCacheSize() -> (Int) {
        return 100 * 1024 * 1024
    }

    class func performDirectoriesCheck() {
        print("EPCache perform start checks")
        EPCache.checkDirectoryExistsCreateIfNot(EPCache.downloadDirectory())
        EPCache.listFilesInDirectoryWithPath(EPCache.downloadDirectory())
        EPCache.checkDirectoryExistsCreateIfNot(EPCache.cacheDirectory())
        EPCache.listFilesInDirectoryWithPath(EPCache.cacheDirectory())
    }

    static func checkDirectoryExistsCreateIfNot(_ path: String) {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            // exists, no action needed
        } else {
            do {
                // file does not exist
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
                
            }
        }
    }

    static func checkTrackFileExistsInDownload(_ track: EPTrack) -> Bool {
        return FileManager.default.fileExists(atPath: pathForTrackToSave(track))
    }

    static func pathForTrackToSave(_ track: EPTrack) -> (String) {
        return (EPCache.downloadDirectory() as NSString).appendingPathComponent("\(track.ID).mp3")
    }

    static func trackCoverImageIfExists(_ track: EPTrack) -> (UIImage?) {
        if let image = UIImage(contentsOfFile: pathForTrackArtwork(track)) {
            print("retrieving image for track \(track.artist) - \(track.title)")
            return image
        } else {
            return nil
        }

    }

    static func cacheStateUponTermination(_ track: EPTrack, playlist: EPMusicPlaylist) -> Bool {

        if playlist.tracks.count == 0 || track.ID == 0 {
            print("cacheStateUponTermination - Fail (Empty track or playlist)")
            return false
        }

        if let responseJSON = playlist.responseJSON {
            //response mode
            //save the JSON first
            if let responseJSONData = try? JSONSerialization.data(withJSONObject: responseJSON, options: JSONSerialization.WritingOptions(rawValue: 0)) {
                if (try? responseJSONData.write(to: URL(fileURLWithPath: (cacheDirectory() as NSString).appendingPathComponent("cachedPlaylist.json")), options: [.atomic])) != nil {
                    //now save the track ID for resuming next time on it
                    UserDefaults.standard.set(track.ID, forKey: "LastTrackID")
                    print("cacheStateUponTermination - OK (JSON)")
                    return true
                }
            }
            print("cacheStateUponTermination - Fail (JSON)")
            return false

        } else {
            //cache mode
            do {
                try FileManager.default.removeItem(atPath: (cacheDirectory() as NSString).appendingPathComponent("cachedPlaylist.json"))
            } catch _ {
                print("remove cached playlist throw")
            }
            print("cacheStateUponTermination - OK (Lib)")
            UserDefaults.standard.set(track.ID, forKey: "LastTrackID")

            return true
        }

    }

    static func cacheStateUponLaunch() -> (track:EPTrack, playlist:EPMusicPlaylist)? {

        if let responseJSONData = try? Data(contentsOf: URL(fileURLWithPath: (cacheDirectory() as NSString).appendingPathComponent("cachedPlaylist.json"))) {
            if let responseJSON = try? JSONSerialization.jsonObject(with: responseJSONData, options: JSONSerialization.ReadingOptions(rawValue: 0)) {
                let playlist = EPMusicPlaylist.initWithResponse(responseJSON as! NSDictionary)
                playlist.identifier = "Cached Generic"
                let lastTrackID = UserDefaults.standard.object(forKey: "LastTrackID") as! Int
                for track in playlist.tracks {
                    if track.ID == lastTrackID {
                        return (track, playlist)
                    }
                }
            }
        } else {
            if let lastTrackID = UserDefaults.standard.object(forKey: "LastTrackID") as? Int {
                let playlist = EPMusicPlaylist.initWithRLMResults(EPTrack.allObjects())
                playlist.identifier = "Cached Library"
                for track in playlist.tracks {
                    if track.ID == lastTrackID {
                        return (track, playlist)
                    }
                }
            }
        }

        return nil
    }

    static func pathForTrackArtwork(_ track: EPTrack) -> (String) {
        return ((EPCache.downloadDirectory() as NSString).appendingPathComponent("artwork") as NSString).appendingPathComponent("\(track.ID).jpg")
    }

    static func listFilesInDirectoryWithPath(_ path: String) {
        print("listFilesInDirectoryWithPath: \(path)")
        let fileManager = FileManager.default
        let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: path)!
        var count = 1

        for _ in enumerator.allObjects {

//            print("\(count) : \(url)")

            count += 1
        }
    }
    
    static func removeAllTracks() {


        do {

            RLMRealm.default().beginWriteTransaction()
            RLMRealm.default().deleteAllObjects()
            try RLMRealm.default().commitWriteTransaction()
            
        } catch {
            
        }
        
        let fileManager = FileManager.default
        
        do {
            let fileList = try fileManager.contentsOfDirectory(atPath: self.cacheDirectory())
            for file in fileList {
                do {
                    try fileManager.removeItem(atPath: file)
                } catch let error as NSError {
                    print("unable to delete file: \(file)\n\(error.description)")
                }
            }
        } catch {
            print("unable to load files at cache directory")
        }
        
        do {
            let fileList = try fileManager.contentsOfDirectory(atPath: self.downloadDirectory())
            for file in fileList {
                do {
                    try fileManager.removeItem(atPath: file)
                } catch let error as NSError {
                    print("unable to delete file: \(file)\n\(error.description)")
                }
            }
        } catch {
            print("unable to load files at download directory")
        }

    }
}
