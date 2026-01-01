//
//  PlanBindings.swift
//  HiRoute
//
//  Created by Jupond on 12/26/25.
//
import SwiftUI

struct PlanBindings {
    private weak var vm: PlanVM?
    
    init(vm: PlanVM) {
        self.vm = vm
    }
    
    /**
     * Plan 메모 바인딩 - 특정 Plan의 메모 편집
     */
    func memo(for planUID: String) -> Binding<String> {
        guard let vm = vm else { return .constant("") }
        
        return Binding(
            get: { [weak vm] in
                guard let vm = vm else { return "" }
                let value = vm.currentPlanList.first(where: { $0.uid == planUID })?.memo ?? ""
                
                #if DEBUG
                print("PlanBindings, memo, GET: planUID=\(planUID), value='\(value)'")
                #endif
                
                return value
            },
            set: { [weak vm] newValue in
                guard let vm = vm else { return }
                
                #if DEBUG
                print("PlanBindings, memo, SET: planUID=\(planUID), newValue='\(newValue)'")
                #endif
                
                // PlanCRUD를 통해 안전하게 업데이트
                vm.planCRUD.updateMemo(planUID: planUID, newMemo: newValue)
                
                #if DEBUG
                print("PlanBindings, memo, AFTER_SET: 메모 업데이트 요청 완료")
                #endif
            }
        )
    }
    
    /**
     * Plan 선택 바인딩 - 현재 선택된 Plan
     */
    var selectedPlan: Binding<PlanModel?> {
        guard let vm = vm else { return .constant(nil) }
        
        return Binding(
            get: { [weak vm] in
                vm?.currentPlan
            },
            set: { [weak vm] newValue in
                vm?.currentPlan = newValue
            }
        )
    }
}
