//
//  EPArtworkSearchQueryFilter.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 06/11/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPArtworkSearchQueryFilter: NSObject {

    static let excludedStrings = ["edit", "remix", ",", ".", "@", "feat", "ft", "featt", "featuring", "|", "Instrumental", "mix", "rework", "cover", "version", "&", "\""]

    class func searchQueryForTrack(_ track: EPTrack) -> String {
        var queryString = "\(track.artist) \(track.title)"

        Performance.measure("filtering") {
            (block: () -> ()) -> () in
            print("filtering...\ninput: \(queryString)")
            //check for [] remove all inbetween

            if let startRange = queryString.range(of: "["), let endRange = queryString.range(of: "]") {
                queryString = queryString.replacingCharacters(in: (startRange.lowerBound..<endRange.upperBound), with: "")
            }
            //check for () remove all inbetween
            if let startRange = queryString.range(of: "("), let endRange = queryString.range(of: ")") {
                queryString = queryString.replacingCharacters(in: (startRange.lowerBound..<endRange.upperBound), with: "")
            }

            for string in self.excludedStrings {
                queryString = queryString.replacingOccurrences(of: string, with: "", options: NSString.CompareOptions.caseInsensitive, range: nil)
            }
            print("output: \(queryString)")
            block()

        }
        return queryString

    }


}
