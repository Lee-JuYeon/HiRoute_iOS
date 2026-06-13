//
//  ListItem.swift
//  HiRoute
//
//  Created by Jupond on 5/6/26.
//

struct ListItem: Codable, Identifiable, Hashable {
    var id: String { label }
    let label: String
    var value: String?
}
