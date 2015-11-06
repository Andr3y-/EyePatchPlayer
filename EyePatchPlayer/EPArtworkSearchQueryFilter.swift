//
//  EPArtworkSearchQueryFilter.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 06/11/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPArtworkSearchQueryFilter: NSObject {
    
    static let excludedStrings = ["edit","remix", ",", ".", "@", "feat", "ft", "featt", "featuring", "|", "Instrumental", "mix", "rework", "cover" , "version", "&", "\"",]
    
    class func searchQueryForTrack(track: EPTrack) -> String {
        var queryString = "\(track.artist) \(track.title)"

        Performance.measure("filtering") { (block: () -> ()) -> () in
            print("filtering...\ninput: \(queryString)")
            //check for [] remove all inbetween
            
            if let startRange = queryString.rangeOfString("["), let endRange = queryString.rangeOfString("]") {
                queryString = queryString.stringByReplacingCharactersInRange(Range<String.Index>(start: startRange.startIndex, end: endRange.endIndex), withString: "")
            }
            
            //check for () remove all inbetween
            if let startRange = queryString.rangeOfString("("), let endRange = queryString.rangeOfString(")") {
                queryString = queryString.stringByReplacingCharactersInRange(Range<String.Index>(start: startRange.startIndex, end: endRange.endIndex), withString: "")
            }
            
            for string in self.excludedStrings {
                queryString = queryString.stringByReplacingOccurrencesOfString(string, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
            }
            print("output: \(queryString)")

            block()


        }
        return queryString

    }
    

}
