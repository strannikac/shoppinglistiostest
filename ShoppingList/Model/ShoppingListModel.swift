//
//  ShoppingListModel.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import Foundation

// MARK: - Shopping List (response)
struct ShoppingListModel: Codable, Equatable {
    let id: Int
    let title: String
    let date: String?
    let position: Int
    let items: [ShoppingListItemModel]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, date
        case position = "pos"
        case items
    }
}
