//
//  PlanBindings.swift
//  HiRoute
//
//  Created by Jupond on 12/26/25.
//
import SwiftUI
struct PlanBindings {
    private weak var vm: ScheduleVM?
    
    init(vm: ScheduleVM) {
        self.vm = vm
    }
    
    /**
     * Plan 메모 바인딩 - 메모리 업데이트만
     */
    func memo(for planUID: String) -> Binding<String> {
        guard let vm = vm else { return .constant("") }
        
        return Binding(
            get: { [weak vm] in
                guard let vm = vm else { return "" }
                // ✅ 직접 조회 (getPlanMemo 메서드가 없어서)
                let value = (vm.selectedSchedule?.planList ?? []).first(where: { $0.uid == planUID })?.memo ?? ""
                
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
                
                // ✅ 메모리만 업데이트 (DB 저장 X)
                vm.updateUiPlanMemo(planUID: planUID, newMemo: newValue)
                
                #if DEBUG
                print("PlanBindings, memo, AFTER_SET: 메모리 업데이트 완료 (DB 저장 안함)")
                #endif
            }
        )
    }
    
    /**
     * Plan 파일 바인딩 - 메모리 업데이트만
     */
    func files(for planUID: String) -> Binding<[FileModel]> {
        guard let vm = vm else { return .constant([]) }
        
        return Binding(
            get: { [weak vm] in
                guard let vm = vm else { return [] }
                // ✅ getFiles 또는 getFilesForPlan 둘 다 같은 기능
                let files = vm.getFiles(planUID: planUID)
                
                #if DEBUG
                print("PlanBindings, files, GET: planUID=\(planUID), count=\(files.count)")
                #endif
                
                return files
            },
            set: { [weak vm] newFiles in
                guard let vm = vm else { return }
                
                #if DEBUG
                print("PlanBindings, files, SET: planUID=\(planUID), count=\(newFiles.count)")
                #endif
                
                // ✅ 메모리만 업데이트 (이미 메모리만 업데이트하는 메서드)
                vm.updateFiles(planUID: planUID, newFiles: newFiles)
                
                #if DEBUG
                print("PlanBindings, files, AFTER_SET: 메모리 업데이트 완료 (DB 저장 안함)")
                #endif
            }
        )
    }
}
