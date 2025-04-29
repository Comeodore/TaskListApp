//
//  ViewController.swift
//  TaskListApp
//
//  Created by Vladimir Maksymchuk on 19.03.2025.
//

import UIKit

class MainViewController: UIViewController {
    
    enum AlertType {
        case addTask
        case editTask
    }
    
    // MARK: - Properties
    public var storageManager: StorageManager = StorageManager.shared
    private let tableView = UITableView()
    lazy private var tasks: [String] = storageManager.fetchTasks().map({$0.title!})
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Task"
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
    
    private func showAlertController(type: AlertType, editTaskIndex: Int? = nil) {
        let actionName = type == .addTask ? "Add" : "Edit"
        
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
            
            switch type {
                case .addTask:
                    tasks.append(taskTitle)
                    storageManager.createTask(title: taskTitle)
                case .editTask:
                    guard let editTaskIndex else { return }
                    tasks[editTaskIndex] = taskTitle
                    storageManager.editTask(taskTitle: taskTitle, index: editTaskIndex)
            }
            tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(mainAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    // MARK: - Add action
    @objc private func addTaskAlert() {
        showAlertController(type: .addTask)
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = tasks[indexPath.row]
        cell.contentConfiguration = config
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showAlertController(type: .editTask, editTaskIndex: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            storageManager.deleteTask(indexPath.row)
            
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            showAlertController(type: .editTask, editTaskIndex: indexPath.row)
            
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

