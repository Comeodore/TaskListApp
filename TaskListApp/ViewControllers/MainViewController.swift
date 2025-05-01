//
//  ViewController.swift
//  TaskListApp
//
//  Created by Vladimir Maksymchuk on 19.03.2025.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    // MARK: Properties
    public var storageManager = StorageManager.shared
    private let tableView = UITableView()
    
    private var doneTasks: Results<Task> {
        storageManager.fetchTasks().filter("isCompleted == true")
    }
    private var undoneTasks: Results<Task> {
        storageManager.fetchTasks().filter("isCompleted == false")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Alert controller
extension MainViewController {
    private func showAlertController(indexPath: IndexPath? = nil) {
        let editMode: Bool = indexPath != nil
        let actionName = editMode ? "Edit" : "Add"
        let alertController = UIAlertController(
            title: "\(actionName) task",
            message: "Type a task name",
            preferredStyle: .alert
        )
        alertController.addTextField { textField in
            textField.placeholder = "Task name"
        }
        
        let mainAction = UIAlertAction(title: actionName, style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alertController.textFields?.first,
                  let taskTitle = textField.text, !taskTitle.isEmpty else { return }
            
            if editMode {
                guard let indexPath else { return }
                storageManager.editTask(task: getCurrentTask(indexPath: indexPath), newTitle: taskTitle)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                storageManager.addTask(taskTitle)
                tableView.insertRows(at: [IndexPath(row: undoneTasks.count - 1, section: 0)], with: .automatic)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(mainAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    // MARK: - Add action
    @objc private func addTaskAlert() {
        showAlertController()
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Task to do" : "Done tasks"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return undoneTasks.count
        }
        return doneTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let currentTask = getCurrentTask(indexPath: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = currentTask.title
        cell.contentConfiguration = config
        cell.accessoryType = currentTask.isCompleted ? .checkmark : .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showAlertController(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentTask = getCurrentTask(indexPath: indexPath)
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, hideButtons) in
            guard let self = self else { return }
            
            storageManager.deleteTask(currentTask)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            hideButtons(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, hideButtons) in
            guard let self = self else { return }
            
            showAlertController(indexPath: indexPath)
            hideButtons(true)
        }
        editAction.backgroundColor = .orange
        
        let taskIsCompleted = currentTask.isCompleted
        let doneButton = UIContextualAction(style: .normal, title: taskIsCompleted ? "Undone" : "Done") { [weak self] (_, _, hideButtons) in
            guard let self = self else { return }
            
            storageManager.editTask(task: currentTask, isCompleted: !taskIsCompleted)
            let targetSection = indexPath.section == 0 ? 1 : 0
            let targetRowIndex = targetSection == 0 ? undoneTasks.index(of: currentTask)! : doneTasks.index(of: currentTask)!
            
//            Alternative move row animation with update checkmark status
//            let destinationRowIndexPath = IndexPath(row: targetRowIndex, section: targetSection)
//            tableView.moveRow(at: indexPath, to: destinationRowIndexPath)
//            tableView.reloadRows(at: [destinationRowIndexPath], with: .automatic)
            
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.insertRows(at: [IndexPath(row: targetRowIndex, section: targetSection)], with: .automatic)
            }, completion: nil)
            hideButtons(true)
        }
        doneButton.backgroundColor = taskIsCompleted ? .purple : .systemGreen
        
        return UISwipeActionsConfiguration(actions: [deleteAction, doneButton, editAction])
    }
}

// MARK: - UI Setup
extension MainViewController {
    private func setupUI() {
        title = "Tasks"
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTaskAlert)
        )
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - Private helper functions
extension MainViewController {
    func getCurrentTask(indexPath: IndexPath) -> Task {
        if indexPath.section == 0 {
            return undoneTasks[indexPath.row]
        }
        return doneTasks[indexPath.row]
    }
}
