//
//  AlertView.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import Foundation
import UIKit

/* MARK: show error or notice in any controller (screen) */

class AlertView {
    
    class func show(title: String, message: String, controller: UIViewController) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: StringConstants.ok.rawValue, style: .default, handler: nil))
        
            controller.present(alertVC, animated: true, completion: nil)
        }
    }
    
    class func show(title: String, message: String, controller: UIViewController, handler: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: StringConstants.ok.rawValue, style: .default, handler: { (action: UIAlertAction!) in
                handler()
            }))
        
            controller.present(alertVC, animated: true, completion: nil)
        }
    }
}
