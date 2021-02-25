//
//  ShoppingListItemTableViewController.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import UIKit

class ShoppingListItemsTableViewController: UITableViewController {
    
    var dataController: DataController!
    
    var list: ShoppingList!
    private var items: [ShoppingListItem] = []
    
    private var activityIndicatorHelper: ActivityIndicatorHelper!
    
    private var isCheckedEditing = false
    private var checkedChanges: [Int:Bool] = [:]
    
    private var addBarButton = UIBarButtonItem()
    private var editBarButton = UIBarButtonItem()
    private var doneBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTable()
    }
    
    private func configureUI() {
        title = list.title
        self.setNavBarTitleFont()
        
        addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        editBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editButtonTapped))
        
        self.navigationItem.rightBarButtonItems = [addBarButton, editBarButton]
        
        tableView.register(ShoppingListItemTableViewCell.self, forCellReuseIdentifier: "ShoppingListItemTableViewCell")
    }
    
    @objc private func addButtonTapped() {
        showEditForm()
    }
    
    @objc private func editButtonTapped() {
        isCheckedEditing = !isCheckedEditing
        
        if isCheckedEditing {
            updateTable()
            self.navigationItem.rightBarButtonItems = [addBarButton, doneBarButton]
        } else {
            let totalCount = checkedChanges.count
            
            if totalCount > 0 {
                var doneCount = 0
                
                let api = APIService()
                activityIndicatorHelper = ActivityIndicatorHelper(forController: self)
                
                for (id, checked) in checkedChanges {
                    var params: [String: Any] = [:]
                    
                    let item = self.items[id]
                    
                    params["checked"] = 0
                    item.checked = false
                    if checked {
                        params["checked"] = 1
                        item.checked = true
                    }
                    
                    api.updateListItem(id: Int(item.id), params: params) { (response, error) in
                        doneCount += 1
                        
                        self.dataController.saveShoppingListItem(list: self.list, model: nil, item: item)
                        
                        if doneCount == totalCount {
                            self.updateTable()
                            self.activityIndicatorHelper.remove()
                            
                            DispatchQueue.main.async {
                                self.navigationItem.rightBarButtonItems = [self.addBarButton, self.editBarButton]
                            }
                        }
                    }
                }
            } else {
                self.updateTable()
                self.navigationItem.rightBarButtonItems = [self.addBarButton, self.editBarButton]
            }
        }
    }
    
    private func showEditForm(_ item: ShoppingListItem? = nil) {
        let vc = ChangeListItemViewController()
        vc.dataController = dataController
        vc.list = list
        
        if let item = item {
            vc.item = item
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateTable() {
        items = []
        
        let parent = dataController.getShoppingList(list.id)
        
        if let parent = parent, let children = parent.items {
            for item in children {
                items.append(item as! ShoppingListItem)
            }
        }
        
        items.sort(by: { $0.position < $1.position })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListItemTableViewCell", for: indexPath) as! ShoppingListItemTableViewCell
        
        let item = items[indexPath.row]
        cell.setup(with: item)
        
        cell.checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        cell.checkButton.isHidden = !isCheckedEditing
        cell.checkButton.tag = indexPath.row
        
        return cell
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
            
            api.deleteListItem(id: Int(self.items[indexPath.row].id)) { (response, error) in
                if let error = error {
                    AlertView.show(title: StringConstants.error.rawValue, message: error, controller: self)
                } else if let response = response {
                    if let error = response.error {
                        AlertView.show(title: StringConstants.error.rawValue, message: error, controller: self)
                    } else {
                        let id = self.items[indexPath.row].id
                        self.items.remove(at: indexPath.row)
                        self.dataController.deleteShoppingListItem(id: id)
                        
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
            self.showEditForm(self.items[indexPath.row])

            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        
        return editAction
    }
    
    @objc private func checkButtonTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        checkedChanges[sender.tag] = sender.isSelected
    }
}
