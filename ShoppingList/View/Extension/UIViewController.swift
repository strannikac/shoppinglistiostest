//
//  UIViewController.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import UIKit

extension UIViewController {
    func setNavBarTitleFont() {
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 20)!,
             NSAttributedString.Key.foregroundColor: UIColor.black]
    }
}
