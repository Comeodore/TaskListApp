//
//  StorageManagerRealm.swift
//  TaskListApp
//
//  Created by Vladimir Maksymchuk on 01.05.2025.
//

import RealmSwift

final class StorageManager {
    static let shared = StorageManager()
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    func fetchTasks() -> Results<Task> {
        realm.objects(Task.self)
    }
    
    func addTask(_ taskTitle: String) {
        addNewObject(Task(value: ["title": taskTitle]))
    }
    
    func editTask(task: Task, newTitle: String? = nil, isCompleted: Bool? = nil) {
        commit {
            if let newTitle {
                task.title = newTitle
            }
            if let isCompleted {
                task.isCompleted = isCompleted
            }
        }
    }
    
    func deleteTask(_ task: Task) {
        commit {
            realm.delete(task)
        }
    }
    
    // MARK: - Private funcs
    
    private func addNewObject<T: Object>(_ object: T) {
        commit {
            realm.add(object)
        }
    }
    
    private func commit(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print("Error when writing to Realm: \(error)")
        }
    }
}
