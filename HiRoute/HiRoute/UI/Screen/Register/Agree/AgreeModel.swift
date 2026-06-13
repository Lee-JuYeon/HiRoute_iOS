//
//  AgreeModel.swift
//  HiRoute
//
//  Created by Jupond on 3/13/26.
//


// 약관 항목 모델
struct AgreeModel: Identifiable {
    let id: String
    let serverId: Int
    let title: String
    let isRequired: Bool
}
