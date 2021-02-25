//
//  ActivityIndicatorHelper.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import Foundation
import UIKit

class ActivityIndicatorHelper {
    private var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    
    private weak var controller: UIViewController!
    
    init(forController controller: UIViewController) {
        self.controller = controller
        create()
    }
    
    func create() {
        DispatchQueue.main.async {
            let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
            self.controller.view.addSubview(indicator)
            
            indicator.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            indicator.color = .red
            indicator.style = .large
            
            indicator.translatesAutoresizingMaskIntoConstraints = false
            
            let w = self.controller.view.bounds.size.width
            let h = self.controller.view.bounds.size.height
            
            indicator.widthAnchor.constraint(equalToConstant: w).isActive = true
            indicator.heightAnchor.constraint(equalToConstant: h).isActive = true
            
            if let vc = self.controller as? UITableViewController {
                let topOffset = vc.tableView.contentOffset.y
                indicator.topAnchor.constraint(equalTo: vc.tableView.topAnchor, constant: topOffset).isActive = true
            }
            
            indicator.hidesWhenStopped = true
            indicator.center = self.controller.view.center
            
            self.activityIndicatorView = indicator
        }
        
        self.set(true)
    }
    
    func set(_ isShow: Bool) {
        DispatchQueue.main.async {
            self.activityIndicatorView.isHidden = !isShow
            self.controller.view.isUserInteractionEnabled = !isShow
            
            isShow ? self.activityIndicatorView.startAnimating() : self.activityIndicatorView.stopAnimating()
        }
    }
    
    func remove() {
        set(false)
        
        DispatchQueue.main.async {
            self.activityIndicatorView.removeFromSuperview()
        }
    }
}
