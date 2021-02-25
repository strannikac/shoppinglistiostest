//
//  RootNavigationController.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 23.02.2021.
//

import UIKit

class RootNavigationController: UINavigationController {
    
    private let dataController = DataController(modelName: "Shopping")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainVC = ShoppingListTableViewController()
        mainVC.dataController = dataController
        
        viewControllers = [mainVC]
    }
}
