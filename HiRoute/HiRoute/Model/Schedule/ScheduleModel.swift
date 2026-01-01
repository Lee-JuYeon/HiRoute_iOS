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
    let planList: [PlanModel]
    
    func updateModel(_ newModel : ScheduleModel) -> ScheduleModel {
        return ScheduleModel(
            uid: newModel.uid,
            index: newModel.index,
            title: newModel.title,
            memo: newModel.memo,  // 새로운 값
            editDate: newModel.editDate,
            d_day: newModel.d_day,
            planList: newModel.planList
        )
    }
}
