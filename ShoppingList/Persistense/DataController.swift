//
//  DataController.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer
    
    lazy var viewContext: NSManagedObjectContext = {
      let context = persistentContainer.viewContext
      context.automaticallyMergesChangesFromParent = true
      context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
      return context
    }()
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        load()
    }
    
    private func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            completion?()
        }
    }
}

//MARK: remove and save data

extension DataController {
    func saveContext(forContext context: NSManagedObjectContext) {
        if context.hasChanges {
            context.performAndWait {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    print("Error when saving! \(nserror.localizedDescription)")
                    print("Callstack:")
                    for symbol: String in Thread.callStackSymbols {
                        print(" > \(symbol)")
                    }
                }
            }
        }
    }
    
    func clearShoppingLists() {
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = viewContext
        
        var deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ShoppingListItem")
        var deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try privateMOC.execute(deleteRequest)
            saveContext(forContext: privateMOC)
            saveContext(forContext: viewContext)
        } catch let error as NSError {
            print("error in clearing data for shopping list item: \(error.localizedDescription)")
        }
        
        deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ShoppingList")
        deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try privateMOC.execute(deleteRequest)
            saveContext(forContext: privateMOC)
            saveContext(forContext: viewContext)
        } catch let error as NSError {
            print("error in clearing data for shopping list: \(error.localizedDescription)")
        }
    }
    
    func saveShoppingLists(lists: [ShoppingListModel]) {
        
        clearShoppingLists()
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = viewContext
        
        for list in lists {
            let shoppingList = ShoppingList(context: privateMOC)
            
            shoppingList.id = Int32(list.id)
            shoppingList.title = list.title
            shoppingList.position = Int32(list.position)
            
            if let date = list.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                shoppingList.date = dateFormatter.date(from: date)!
            }
            
            if let items = list.items {
                for item in items {
                    let shoppingItem = ShoppingListItem(context: privateMOC)
                    
                    shoppingItem.id = Int32(item.id)
                    shoppingItem.title = item.title
                    shoppingItem.position = Int32(item.position)
                    
                    shoppingItem.checked = false
                    if item.status == 2 {
                        shoppingItem.checked = true
                    }
                    
                    shoppingItem.list = shoppingList
                }
            }
        }
        
        saveContext(forContext: privateMOC)
        saveContext(forContext: viewContext)
    }
    
    func saveShoppingList(model: ShoppingListModel?, list: ShoppingList?) {
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = viewContext
        
        var shoppingList: ShoppingList
        
        if let list = list {
            shoppingList = list
        } else if let model = model {
            shoppingList = ShoppingList(context: privateMOC)
            shoppingList.id = Int32(model.id)
            
            shoppingList.title = model.title
            shoppingList.position = Int32(model.position)
            
            if let date = model.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                shoppingList.date = dateFormatter.date(from: date)!
            }
        }
        
        saveContext(forContext: privateMOC)
        saveContext(forContext: viewContext)
    }
    
    func deleteShoppingList(id: Int32) {
        let fetchRequest: NSFetchRequest<ShoppingList> = ShoppingList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            if result.count > 0 {
                for obj in result {
                    viewContext.delete(obj)
                }
            }
            
            saveContext(forContext: viewContext)
        } catch {
            print("select shopping list from local error: \(id)")
        }
    }
    
    func saveShoppingListItem(list: ShoppingList, model: ShoppingListItemModel?, item: ShoppingListItem?) {
        var shoppingListItem: ShoppingListItem
        
        if let item = item {
            shoppingListItem = item
        } else if let model = model {
            shoppingListItem = ShoppingListItem(context: viewContext)
            shoppingListItem.id = Int32(model.id)
            
            shoppingListItem.title = model.title
            shoppingListItem.position = Int32(model.position)
            
            shoppingListItem.checked = false
            if model.status == 2 {
                shoppingListItem.checked = true
            }
            
            shoppingListItem.list = list
        }
        
        saveContext(forContext: viewContext)
    }
    
    func deleteShoppingListItem(id: Int32) {
        let fetchRequest: NSFetchRequest<ShoppingListItem> = ShoppingListItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            if result.count > 0 {
                for obj in result {
                    viewContext.delete(obj)
                }
            }
            
            saveContext(forContext: viewContext)
        } catch {
            print("select shopping list item from local error: \(id)")
        }
    }
}

//MARK: select data

extension DataController {
    func getShoppingLists() -> [ShoppingList] {
        let fetchRequest: NSFetchRequest<ShoppingList> = ShoppingList.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptor3 = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor, sortDescriptor2, sortDescriptor3]
        
        var result: [ShoppingList] = []
    
        do {
            result = try viewContext.fetch(fetchRequest)
        } catch {
            result = []
            print("error selecting shopping lists from local")
        }
        
        return result
    }
    
    func getShoppingList(_ id: Int32) -> ShoppingList? {
        let fetchRequest: NSFetchRequest<ShoppingList> = ShoppingList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            if result.count > 0 {
                return result[0]
            }
        } catch {
            print("select shopping list from local error: \(id)")
        }
        
        return nil
    }
}
