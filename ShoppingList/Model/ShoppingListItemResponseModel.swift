//
//  ShoppingListItemResponseModel.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 24.02.2021.
//

import Foundation

// MARK: - Shopping List Item Response
struct ShoppingListItemResponseModel: Codable, Equatable {
    let time: String?
    let controller: String?
    let action: String?
    let method: String?
    let items: [ShoppingListItemModel]?
    let status: String?
    let error: String?
    let msg: String?
}
