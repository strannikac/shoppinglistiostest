//
//  ShoppingListItemTableViewCell.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 24.02.2021.
//

import UIKit

class ShoppingListItemTableViewCell: UITableViewCell {

    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let checkButton: UIButton = {
        let btn = UIButton()
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.setBackgroundImage(UIImage(systemName: "checkmark"), for: .selected)
        btn.isHidden = true
        return btn
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.isUserInteractionEnabled = true
        
        addSubview(titleLabel)
        addSubview(checkButton)
        
        checkButton.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, padding: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 0), width: 16, height: 16, enableInsets: false)
        
        titleLabel.anchor(top: topAnchor, left: checkButton.rightAnchor, bottom: nil, right: rightAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 1, right: 0), width: 0, height: 0, enableInsets: false)
        
        checkButton.centerByY(self.centerYAnchor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with item: ShoppingListItem) {
        titleLabel.text = item.title
        
        let attributeString =  NSMutableAttributedString(string: item.title!)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))

        let removedAttributeString = NSMutableAttributedString(string: item.title!)
        removedAttributeString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, removedAttributeString.length))
        
        titleLabel.attributedText = removedAttributeString
        
        if item.checked {
            checkButton.isSelected = true
            titleLabel.attributedText = attributeString
        }
    }
}
