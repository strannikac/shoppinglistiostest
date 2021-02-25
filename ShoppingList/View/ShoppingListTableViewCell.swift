//
//  ShoppingListTableViewCell.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import UIKit

class ShoppingListTableViewCell: UITableViewCell {

    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let infoLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.isUserInteractionEnabled = true
        
        addSubview(titleLabel)
        addSubview(infoLabel)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 1, right: 0), width: 0, height: 0, enableInsets: false)
        
        infoLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 0), width: 0, height: 0, enableInsets: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with list: ShoppingList) {
        titleLabel.text = list.title
        
        var info = ""
        
        if let date = list.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            info = StringConstants.date.rawValue + ": " + dateFormatter.string(from: date)
        }
        
        if let items = list.items {
            let count = items.count
            
            if info != "" {
                info += ", "
            }
            info += StringConstants.items.rawValue + ": \(count)"
            
            if count > 0 {
                var checkedCount = 0
                
                for item in items {
                    let obj = item as! ShoppingListItem
                    
                    if obj.checked {
                        checkedCount += 1
                    }
                }
                
                info += ", " + StringConstants.checked.rawValue + ": \(checkedCount)"
            }
        }
        
        infoLabel.text = info
    }
}
