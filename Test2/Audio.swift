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
    @objc dynamic var recordDuration: Double = 0
}

let config = Realm.Configuration(
    schemaVersion: 1,
    migrationBlock: { migration, oldSchemaVersion in
        if (oldSchemaVersion < 1) {
            migration.enumerateObjects(ofType: Audio.className()) { (oldObject, newObject) in
                let recordData = oldObject!["recordData"] as? Data
                let recordDate = oldObject!["recordDate"] as? Date
                newObject!["recordDuration"] = 0.0 
            }
        }
        
})
