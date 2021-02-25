//
//  ChangeListViewController.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 23.02.2021.
//

import UIKit

class ChangeListViewController: UIViewController {
    
    var dataController: DataController!
    
    var list: ShoppingList?
    
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
    private let dateTextField = UITextField()
    private let positionTextField = UITextField()
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
        
        dateTextField.placeholder = StringConstants.date.rawValue
        dateTextField.textColor = textFontColor
        dateTextField.font = textFont
        dateTextField.borderStyle = UITextField.BorderStyle.line
        dateTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged), for: UIControl.Event.valueChanged)
        datePicker.preferredDatePickerStyle = .wheels
        dateTextField.inputView = datePicker
        
        positionTextField.placeholder = StringConstants.position.rawValue
        positionTextField.textColor = textFontColor
        positionTextField.font = textFont
        positionTextField.borderStyle = UITextField.BorderStyle.line
        positionTextField.layer.borderColor = UIColor.lightGray.cgColor
        positionTextField.keyboardType = .numberPad
        
        saveButton.setTitle(StringConstants.save.rawValue, for: .normal)
        saveButton.titleLabel?.font = btnFont
        saveButton.setTitleColor(btnFontColor, for: .normal)
        saveButton.backgroundColor = btnBgColor
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        title = StringConstants.addList.rawValue
        
        if let list = self.list {
            title = StringConstants.editList.rawValue
            titleTextField.text = list.title
            
            if let date = list.date {
                dateTextField.text = dateFormatter.string(from: date)
            }
            
            positionTextField.text = "\(Int(list.position))"
        }
        
        self.setNavBarTitleFont()
        
        contentView.addSubview(titleTextField)
        contentView.addSubview(dateTextField)
        contentView.addSubview(positionTextField)
        contentView.addSubview(saveButton)
        
        titleTextField.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, padding: elementPadding, width: 0, height: elementHeight, enableInsets: false)
        
        dateTextField.anchor(top: titleTextField.bottomAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, padding: elementPadding, width: 0, height: elementHeight, enableInsets: false)
        
        positionTextField.anchor(top: dateTextField.bottomAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, padding: elementPadding, width: 0, height: elementHeight, enableInsets: false)
        
        saveButton.anchor(top: positionTextField.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, padding: elementPadding, width: 0, height: elementHeight, enableInsets: false)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTouched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(recognizer)
    }
    
    @objc func viewTouched() {
        self.view.endEditing(true)
    }
    
    @objc private func dateChanged(sender: UIDatePicker) {
        dateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc private func saveButtonTapped() {
        if titleTextField.text == "" || dateTextField.text == "" {
            AlertView.show(title: StringConstants.error.rawValue, message: StringConstants.errEmptyData.rawValue, controller: self)
            return
        }
        
        var params: [String: Any] = [:]
        params["title"] = titleTextField.text
        params["date"] = dateTextField.text
        params["pos"] = positionTextField.text
        
        activityIndicatorHelper = ActivityIndicatorHelper(forController: self)
        
        let api = APIService()
        
        if let list = self.list {
            api.updateList(id: Int(list.id), params: params, completion: updatedResponse(response:error:))
        } else {
            api.addList(params: params, completion: addedResponse(model:error:))
        }
    }
    
    private func addedResponse(model: ShoppingListModel?, error: String?) {
        if let error = error {
            AlertView.show(title: StringConstants.error.rawValue, message: error, controller: self)
        } else {
            if let model = model {
                dataController.saveShoppingList(model: model, list: nil)
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
                    if let list = self.list {
                        list.title = titleTextField.text!
                        list.position = Int32(positionTextField.text!)!
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd.MM.yyyy"
                        
                        list.date = dateFormatter.date(from: dateTextField.text!)
                        
                        dataController.saveShoppingList(model: nil, list: list)
                    }
                }
            }
        }
        
        activityIndicatorHelper.remove()
    }
}
