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
        return miliSeconds / 600
    }
    var seconds: Int {
        return miliSeconds / 10  - minuts * 60
    }
    var miliSeconds: Int
    
    
    
    var description: String {
        
        guard seconds > 9 else {
            return " 0\(minuts) : 0\(seconds),\(miliSeconds - seconds * 10 - minuts * 600)"
        }
        guard minuts > 9 else {
            return " 0\(minuts) : \(seconds),\(miliSeconds - seconds * 10 - minuts * 600)"
        }
        
        return " \(minuts) : \(seconds),\(miliSeconds - seconds * 10 - minuts * 600)"
    }
    
    init() {
        self.miliSeconds = 0
    }
}
