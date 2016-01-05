//
//  Array.swift
//  Virtual Tourist
//
//  Created by arianne on 2015-12-27.
//  Copyright © 2015 della. All rights reserved.
//

import Foundation

//array extension
//http://iphonedev.tv/blog/2015/9/22/how-to-remove-an-array-of-objects-from-a-swift-2-array-removeobjectsinarray
// Swift 2 Array Extension
extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    //remove sub array form bigger array
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}