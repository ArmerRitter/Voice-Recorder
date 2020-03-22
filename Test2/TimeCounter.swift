//
//  TimeCounter.swift
//  Test2
//
//  Created by Yuriy Balabin on 14.03.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation


struct TimeCounter: CustomStringConvertible {
    
    var minuts: Int {
        return deciSeconds / 600
    }
    var seconds: Int {
        return deciSeconds / 10  - minuts * 60
    }
    var deciSeconds: Int
    
    
    
    var description: String {
        
        guard seconds > 9 else {
            return " 0\(minuts) : 0\(seconds),\(deciSeconds - seconds * 10 - minuts * 600)"
        }
        guard minuts > 9 else {
            return " 0\(minuts) : \(seconds),\(deciSeconds - seconds * 10 - minuts * 600)"
        }
        return " \(minuts) : \(seconds),\(deciSeconds - seconds * 10 - minuts * 600)"
    }
    
    
    var descriptionSecond: String {
        
        guard seconds > 9 else {
            return " 0\(minuts):0\(seconds)"
        }
        guard minuts > 9 else {
            return " 0\(minuts):\(seconds)"
        }
        return " \(minuts):\(seconds)"
    }
    
    var descriptionThird: String {
           
           guard seconds > 9 else {
               return "-0\(minuts):0\(seconds)"
           }
           guard minuts > 9 else {
               return "-0\(minuts):\(seconds)"
           }
           return "-\(minuts):\(seconds)"
       }
    
    init() {
        self.deciSeconds = 0
    }
}
