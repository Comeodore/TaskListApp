//
//  TaskList.swift
//  TaskListApp
//
//  Created by Vladimir Maksymchuk on 01.05.2025.
//

import RealmSwift

final class Task: Object {
    @Persisted var title: String
    @Persisted var isCompleted: Bool = false
}
