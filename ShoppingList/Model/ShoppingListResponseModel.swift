//
//  ShoppingListResponseModel.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import Foundation

// MARK: - Shopping List Response
struct ShoppingListResponseModel: Codable, Equatable {
    let time: String?
    let controller: String?
    let action: String?
    let method: String?
    let items: [ShoppingListModel]?
    let status: String?
    let error: String?
    let msg: String?
}
