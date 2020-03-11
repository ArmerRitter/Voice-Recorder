//
//  Audio.swift
//  Test2
//
//  Created by Yuriy Balabin on 10.03.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation
import RealmSwift

class Audio: Object {
   @objc dynamic var recordData: Data? = nil
   @objc dynamic var recordDate: Date? = nil
}
