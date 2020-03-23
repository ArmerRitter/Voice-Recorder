//
//  StorageManager.swift
//  Test2
//
//  Created by Yuriy Balabin on 10.03.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation
import RealmSwift


class StorageManager {
    
    private var storage: Realm
    static let shared = StorageManager()
    
    private init() {
        self.storage = try! Realm()
    }
    
    func addRecord(object: Audio) {
        try! storage.write {
            storage.add(object)
        }
    }
    
    func fetchRecords() -> Results<Audio> {
        let results: Results<Audio> = storage.objects(Audio.self)
        return results
    }
    
    func deleteRecord(object: Audio) {
        try! storage.write {
            storage.delete(object)
        }
    }
    
    func deleteAll()  {
         try! storage.write {
             storage.deleteAll()
         }
    }
}
