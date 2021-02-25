//
//  APIService.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import Foundation

//MARK: api for requests

class APIService {
    
    enum Endpoints {
        static let base = "https://boom.place/shopping/"
        
        case lists
        case add
        case update(Int)
        case delete(Int)
        case addItem(Int)
        case updateItem(Int)
        case deleteItem(Int)
        
        var stringValue: String {
            switch self {
            case .lists:
                return Endpoints.base
            case .add:
                return Endpoints.base
            case .update(let id):
                return Endpoints.base + "\(id)/"
            case .delete(let id):
                return Endpoints.base + "\(id)/"
            case .addItem(let parent):
                return Endpoints.base + "\(parent)/"
            case .updateItem(let id):
                return Endpoints.base + "item/\(id)/"
            case .deleteItem(let id):
                return Endpoints.base + "item/\(id)/"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    @discardableResult func taskForRequest<ResponseType: Decodable>(
        url: URL,
        method: String,
        params: [String: Any]?,
        responseType: ResponseType.Type,
        completion: @escaping (ResponseType?, String?) -> Void
    ) -> URLSessionTask {
        
        var paramsString = ""
        
        if let params = params {
            paramsString = params.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if method == "POST" || method == "PUT" {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = paramsString.data(using: String.Encoding.utf8)
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(nil, error?.localizedDescription)
                return
            }
            
            let decoder = JSONDecoder()
        
            do {
                let responseObject = try decoder.decode(responseType.self, from: data)
                
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                completion(nil, error.localizedDescription)
            }
        }
        
        task.resume()
        
        return task
    }
    
    //MARK: list of shopping lists
    
    func getLists(completion: @escaping ([ShoppingListModel], String?) -> Void) {
        self.taskForRequest(url: Endpoints.lists.url, method: "GET", params: nil, responseType: ShoppingListResponseModel.self) { response, error in
            if let response = response {
                completion(response.items!, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    //MARK: add, update shopping list
    
    func addList(params: [String: Any], completion: @escaping (ShoppingListModel?, String?) -> Void) {
        self.taskForRequest(url: Endpoints.add.url, method: "POST", params: params, responseType: ShoppingListResponseModel.self) { response, error in
            if let response = response {
                completion(response.items![0], nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func updateList(id: Int, params: [String: Any], completion: @escaping (ShoppingListResponseModel?, String?) -> Void) {
        self.taskForRequest(url: Endpoints.update(id).url, method: "PUT", params: params, responseType: ShoppingListResponseModel.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func deleteList(id: Int, completion: @escaping (ShoppingListResponseModel?, String?) -> Void) {
        self.taskForRequest(url: Endpoints.delete(id).url, method: "DELETE", params: nil, responseType: ShoppingListResponseModel.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    //MARK: add, update shopping list item
    
    func addListItem(parent: Int, params: [String: Any], completion: @escaping (ShoppingListItemModel?, String?) -> Void) {
        self.taskForRequest(url: Endpoints.addItem(parent).url, method: "POST", params: params, responseType: ShoppingListItemResponseModel.self) { response, error in
            if let response = response {
                completion(response.items![0], nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func updateListItem(id: Int, params: [String: Any], completion: @escaping (ShoppingListResponseModel?, String?) -> Void) {
        self.taskForRequest(url: Endpoints.updateItem(id).url, method: "PUT", params: params, responseType: ShoppingListResponseModel.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func deleteListItem(id: Int, completion: @escaping (ShoppingListResponseModel?, String?) -> Void) {
        self.taskForRequest(url: Endpoints.deleteItem(id).url, method: "DELETE", params: nil, responseType: ShoppingListResponseModel.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}
