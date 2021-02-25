//
//  ShoppingListItemModel.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import Foundation

// MARK: - Shopping List Item (response)
struct ShoppingListItemModel: Codable, Equatable {
    let id: Int
    let title: String
    let position: Int
    let status: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case position = "pos"
        case status
    }
}
