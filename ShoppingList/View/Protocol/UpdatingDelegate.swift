//
//  UpdatingTableDelegate.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import UIKit

//MARK: protocol for updating data in view controller

protocol UpdatingTableDelegate: UITableViewController {
    func didUpdate(items: [ShoppingListModel])
}
