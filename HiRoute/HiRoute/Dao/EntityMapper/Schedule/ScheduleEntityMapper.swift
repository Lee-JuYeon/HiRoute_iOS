//
//  ScheduleEntityMapper.swift
//  HiRoute
//
//  Created by Jupond on 1/21/26.
//

import Foundation
import CoreData

struct ScheduleEntityMapper {
    static func toModel(_ entity: ScheduleEntity?, fullData: Bool = true) -> ScheduleModel? {
        guard let entity = entity,
              let uid = entity.uid else { return nil }
        
        // PlanEntity -> PlanModel 변환
        let plans = PlanEntityMapper.toModels(entity.planList as? Set<PlanEntity>, fullData: fullData)
        
        return ScheduleModel(
            uid: uid,
            index: Int(entity.index),
            title: entity.title ?? "",
            memo: entity.memo ?? "",
            editDate: entity.editDate ?? Date(),
            d_day: entity.d_day ?? Date(),
            planList: plans
        )
    }
    
    static func toModels(_ entities: [ScheduleEntity], fullData: Bool = true) -> [ScheduleModel] {
        return entities.compactMap { toModel($0, fullData: fullData) }
    }
    
    static func toEntity(_ model: ScheduleModel, context: NSManagedObjectContext) -> ScheduleEntity {
        let entity = ScheduleEntity(context: context)
        /*
         Entity 객체의 속성값 설정
         Key-Value Coding 방식으로 저장
         여전히 메모리에만 존재
         */
        entity.uid = model.uid
        entity.index = Int32(model.index)
        entity.title = model.title
        entity.memo = model.memo
        entity.editDate = model.editDate
        entity.d_day = model.d_day
        
        /*
         관계설정 1:n
         PlanEntity 객체들을 메모리에 생성
         addToPlanList()로 Foreign Key 관계 설정
         ScheduleEntity ↔ PlanEntity 양방향 관계 구성
         */
        for plan in model.planList {
            let planEntity = PlanEntityMapper.toEntity(plan, schedule: entity, context: context)
            entity.addToPlanList(planEntity)
        }
        
        return entity
    }
}
