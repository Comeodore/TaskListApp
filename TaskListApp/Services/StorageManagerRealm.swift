//
//  StorageManagerRealm.swift
//  TaskListApp
//
//  Created by Vladimir Maksymchuk on 01.05.2025.
//

import RealmSwift

final class StorageManager {
    let shared = StorageManager()
    
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    func fetchData<T: RealmFetchable>(_ type: T.Type) -> Results<T> {
        realm.objects(T.self)
    }
    
    func save<T: Object>(_ object: T) {
        write {
            realm.add(object)
        }
    }
    
    private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print("Error when writing to Realm: \(error)")
        }
    }
}
