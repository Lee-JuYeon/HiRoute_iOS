//
//  CacheableModel.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//

protocol CacheableModel: Codable {
    var uid: String { get }
    var lastModified: Date { get }
    var version: Int { get }
    var contentHash: String { get }
}
