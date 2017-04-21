//
//  ShuffleArray.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 01/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

extension Collection where Index == Int {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        print("\(#function) empty")
    }
}
