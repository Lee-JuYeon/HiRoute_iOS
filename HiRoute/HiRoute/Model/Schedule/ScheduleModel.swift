//
//  AnnotationModel.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//
import Foundation

struct ScheduleModel: Codable, Identifiable {
    var id: String { uid } // ✅ Identifiable 프로토콜 구현
    
    let uid: String
    let index: Int
    let title: String
    let memo: String
    let editDate: Date
    let d_day: Date
    let visitPlaceList: [VisitPlaceModel]
}
