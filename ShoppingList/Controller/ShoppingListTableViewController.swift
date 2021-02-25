//
//  ShoppingListTableViewController.swift.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import UIKit

class ShoppingListTableViewController: UITableViewController {
    
    var dataController: DataController!
    
    private var lists: [ShoppingList] = []
    
    private var activityIndicatorHelper: ActivityIndicatorHelper!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        updateData(checkTime: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTable()
    }
    
    private func configureUI() {
        title = StringConstants.allLists.rawValue
        self.setNavBarTitleFont()
        
        let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonTapped))
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
        self.navigationItem.rightBarButtonItem = addItem
        self.navigationItem.leftBarButtonItem = refreshItem
        
        tableView.register(ShoppingListTableViewCell.self, forCellReuseIdentifier: "ShoppingListTableViewCell")
    }
    
    private func updateData(checkTime: Bool = true) {
        activityIndicatorHelper = ActivityIndicatorHelper(forController: self)
        let updater = UpdaterService()
        updater.startUpdate(controllerDelegate: self, checkTime: checkTime)
    }
    
    @objc private func refreshButtonTapped() {
        updateData()
    }
    
    @objc private func addButtonTapped() {
        showEditForm()
    }
    
    private func showEditForm(_ list: ShoppingList? = nil) {
        let vc = ChangeListViewController()
        vc.dataController = dataController
        
        if let list = list {
            vc.list = list
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateTable() {
        lists = dataController.getShoppingLists()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListTableViewCell", for: indexPath) as! ShoppingListTableViewCell
        
        let list = lists[indexPath.row]
        cell.setup(with: list)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ShoppingListItemsTableViewController()
        vc.dataController = dataController
        
        vc.list = lists[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            makeDeleteContextualAction(forRowAt: indexPath),
            makeEditContextualAction(forRowAt: indexPath)
        ])
    }
    
    //MARK: Contextual Actions (edit, delete)
    
    private func makeDeleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .destructive, title: "Delete") { (action, swipeButtonView, completion) in
            let api = APIService()
            
            api.deleteList(id: Int(self.lists[indexPath.row].id)) { (response, error) in
                if let error = error {
                    AlertView.show(title: StringConstants.error.rawValue, message: error, controller: self)
                } else if let response = response {
                    if let error = response.error {
                        AlertView.show(title: StringConstants.error.rawValue, message: error, controller: self)
                    } else {
                        let id = self.lists[indexPath.row].id
                        self.lists.remove(at: indexPath.row)
                        self.dataController.deleteShoppingList(id: id)
                        
                        self.tableView.performBatchUpdates({
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        }) { (finished) in
                            self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows!, with: .automatic)
                        }
                    }
                }
            }

            completion(true)
        }
    }
    
    private func makeEditContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, swipeButtonView, completion) in
            self.showEditForm(self.lists[indexPath.row])

            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        
        return editAction
    }
}

//MARK: protocol implementation for updating table view

extension ShoppingListTableViewController: UpdatingTableDelegate {
    func didUpdate(items: [ShoppingListModel]) {
        if items.count > 0 {
            dataController.saveShoppingLists(lists: items)
        }
        
        updateTable()
        
        activityIndicatorHelper.remove()
    }
}
