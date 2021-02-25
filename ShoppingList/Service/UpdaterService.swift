//
//  UpdaterService.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import Foundation

//MARK: Updater Service - update beers list

class UpdaterService {
    
    private let updateTimeSeconds: Int64 = 1800
    
    private var isUpdatingData = false
    private var checkUpdatingTime = true
    
    private weak var updatingController: UpdatingTableDelegate!
    
    private let api: APIService
    
    private var lists: [ShoppingListModel] = []
    
    init() {
        api = APIService()
    }
    
    //MARK: updating process functions
    
    func startUpdate(controllerDelegate controller: UpdatingTableDelegate, checkTime: Bool = true) {
        let isTIme = isUpdateTime()
        
        if !isUpdatingData && (!checkTime || isTIme) {
            isUpdatingData = true
            
            checkUpdatingTime = checkTime
            updatingController = controller
            lists = []
            
            api.getLists(completion: saveResponseData(items:error:))
        } else {
            isUpdatingData = false
            controller.didUpdate(items: [])
        }
    }
    
    private func saveResponseData(items: [ShoppingListModel], error: String?) {
        if let error = error {
            //self.error = error
            lists = []
            
            AlertView.show(title: StringConstants.error.rawValue, message: error, controller: updatingController!)
        } else {
            self.lists = items
        }
        
        self.isUpdatingData = false
        
        updatingController?.didUpdate(items: lists)
    }
    
    func isUpdateTime() -> Bool {
        if let lastTime = UserDefaults.standard.object(forKey: "lastUpdatedTime") as? Int64 {
            let nowSeconds = getSeconds()
            
            if (nowSeconds - lastTime) < updateTimeSeconds {
                return false
            }
        }
        
        return true
    }
    
    func getSeconds(forDate date: Date = Date()) -> Int64 {
        return Int64(date.timeIntervalSince1970)
    }
}
