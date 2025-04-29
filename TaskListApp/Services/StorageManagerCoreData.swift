//
//  StorageManagerCoreData.swift
//  TaskListApp
//
//  Created by Vladimir Maksymchuk on 19.03.2025.
//

import CoreData

final class StorageManagerCoreData {
    static let shared = StorageManagerCoreData()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskListApp")
        container.loadPersistentStores { description, error in
            if let error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func createTask(title: String) {
        let task = Task(context: context)
        task.title = title
        saveContext()
    }
    
    func fetchTasks() -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    func deleteTask(_ taskIndex: Int) {
        context.delete(fetchTasks()[taskIndex])
        saveContext()
    }
    
    func editTask(taskTitle: String, index: Int) {
        let tasks = fetchTasks()
        tasks[index].title = taskTitle
        saveContext()
    }
}
