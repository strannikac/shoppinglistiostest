//
//  ChangeListItemViewController.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 24.02.2021.
//

import UIKit

class ChangeListItemViewController: UIViewController {
    
    var dataController: DataController!
    
    var list: ShoppingList!
    var item: ShoppingListItem?
    
    private let textFont = UIFont.systemFont(ofSize: 16)
    private let textFontColor = UIColor.black
    
    private let btnFont = UIFont(name: "Chalkduster", size: 18)!
    private let btnBgColor = UIColor.systemBlue
    private let btnFontColor = UIColor.white
    
    private let elementPadding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    private let elementHeight: CGFloat = 40
    
    private let dateFormatter = DateFormatter()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var safeArea: UILayoutGuide!
    
    private let titleTextField = UITextField()
    private let positionTextField = UITextField()
    private let checkedLabel = UILabel()
    private let checkedButton = UIButton()
    private let saveButton = UIButton()
    
    private var activityIndicatorHelper: ActivityIndicatorHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.anchor(top: safeArea.topAnchor, bottom: safeArea.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        
        contentView.fillSuperview()
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        titleTextField.placeholder = StringConstants.title.rawValue
        titleTextField.textColor = textFontColor
        titleTextField.font = textFont
        titleTextField.borderStyle = UITextField.BorderStyle.line
        titleTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        positionTextField.placeholder = StringConstants.position.rawValue
        positionTextField.textColor = textFontColor
        positionTextField.font = textFont
        positionTextField.borderStyle = UITextField.BorderStyle.line
        positionTextField.layer.borderColor = UIColor.lightGray.cgColor
        positionTextField.keyboardType = .numberPad
        
        checkedButton.layer.borderWidth = 1.0
        checkedButton.layer.borderColor = UIColor.lightGray.cgColor
        checkedButton.setBackgroundImage(UIImage(systemName: "checkmark"), for: .selected)
        checkedButton.addTarget(self, action: #selector(checkedButtonTapped), for: .touchUpInside)
        
        checkedLabel.text = StringConstants.checked.rawValue
        
        saveButton.setTitle(StringConstants.save.rawValue, for: .normal)
        saveButton.titleLabel?.font = btnFont
        saveButton.setTitleColor(btnFontColor, for: .normal)
        saveButton.backgroundColor = btnBgColor
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        title = StringConstants.addItem.rawValue
        
        if let item = self.item {
            title = StringConstants.editItem.rawValue
            titleTextField.text = item.title
            positionTextField.text = "\(Int(item.position))"
            
            if item.checked {
                checkedButton.isSelected = true
            }
        }
        
        self.setNavBarTitleFont()
        
        contentView.addSubview(titleTextField)
        contentView.addSubview(positionTextField)
        contentView.addSubview(checkedButton)
        contentView.addSubview(checkedLabel)
        contentView.addSubview(saveButton)
        
        titleTextField.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, padding: elementPadding, width: 0, height: elementHeight, enableInsets: false)
        
        positionTextField.anchor(top: titleTextField.bottomAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, padding: elementPadding, width: 0, height: elementHeight, enableInsets: false)
        
        checkedButton.anchor(top: positionTextField.bottomAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, padding: elementPadding, width: elementHeight, height: elementHeight, enableInsets: false)
        
        checkedLabel.anchor(top: checkedButton.topAnchor, left: checkedButton.rightAnchor, bottom: nil, right: contentView.rightAnchor, padding: elementPadding, width: 0, height: 0, enableInsets: false)
        
        saveButton.anchor(top: checkedButton.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, padding: elementPadding, width: 0, height: elementHeight, enableInsets: false)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTouched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(recognizer)
    }
    
    @objc func viewTouched() {
        self.view.endEditing(true)
    }
    
    @objc private func checkedButtonTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func saveButtonTapped() {
        if titleTextField.text == "" {
            AlertView.show(title: StringConstants.error.rawValue, message: StringConstants.errEmptyData.rawValue, controller: self)
            return
        }
        
        var params: [String: Any] = [:]
        params["title"] = titleTextField.text
        params["pos"] = positionTextField.text
        
        params["checked"] = 0
        if checkedButton.isSelected {
            params["checked"] = 1
        }
        
        activityIndicatorHelper = ActivityIndicatorHelper(forController: self)
        
        let api = APIService()
        
        if let item = self.item {
            api.updateListItem(id: Int(item.id), params: params, completion: updatedResponse(response:error:))
        } else {
            api.addListItem(parent: Int(list.id), params: params, completion: addedResponse(model:error:))
        }
    }
    
    private func addedResponse(model: ShoppingListItemModel?, error: String?) {
        if let error = error {
            AlertView.show(title: StringConstants.error.rawValue, message: error, controller: self)
        } else {
            if let model = model {
                dataController.saveShoppingListItem(list: self.list, model: model, item: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        activityIndicatorHelper.remove()
    }
    
    private func updatedResponse(response: ShoppingListResponseModel?, error: String?) {
        if let error = error {
            AlertView.show(title: StringConstants.error.rawValue, message: error, controller: self)
        } else {
            if let response = response {
                if let error = response.error {
                        AlertView.show(title: StringConstants.error.rawValue, message: error, controller: self)
                } else {
                    if let item = self.item {
                        item.title = titleTextField.text!
                        item.position = Int32(positionTextField.text!)!
                        
                        item.checked = false;
                        if checkedButton.isSelected {
                            item.checked = true
                        }
                        
                        dataController.saveShoppingListItem(list: self.list, model: nil, item: item)
                    }
                }
            }
        }
        
        activityIndicatorHelper.remove()
    }
}
