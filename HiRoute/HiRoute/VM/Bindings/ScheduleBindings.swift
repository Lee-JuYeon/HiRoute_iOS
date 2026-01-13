//
//  Persistence.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct ScheduleBindings {
    private weak var vm: ScheduleVM?
    
    init(vm: ScheduleVM) {
        self.vm = vm
    }
    
    func title(scheduleUID: String) -> Binding<String> {
        guard let vm = vm else { return .constant("") }
        
        return Binding(
            get: { [weak vm] in
                guard let vm = vm else { return "" }
                let value = vm.selectedSchedule?.title ?? ""
                
                #if DEBUG
                print("ScheduleBindings, title, GET: scheduleUID=\(scheduleUID), value='\(value)'")
                #endif
                
                return value
            },
            set: { [weak vm] newValue in
                guard let vm = vm else { return }
                
                #if DEBUG
                print("ScheduleBindings, title, SET: scheduleUID=\(scheduleUID), newValue='\(newValue)'")
                #endif
                
                // ScheduleCRUD를 통해 안전하게 업데이트
                if let schedule = vm.selectedSchedule {
                    vm.scheduleCRUD.updateScheduleInfo(
                        uid: schedule.uid,
                        title: newValue,
                        memo: schedule.memo,
                        dDay: schedule.d_day
                    )
                }
                
                #if DEBUG
                print("ScheduleBindings, title, AFTER_SET: 제목 업데이트 요청 완료")
                #endif
            }
        )
    }
    
    func memo(scheduleUID: String) -> Binding<String> {
        guard let vm = vm else { return .constant("") }
        
        return Binding(
            get: { [weak vm] in
                guard let vm = vm else { return "" }
                let value = vm.selectedSchedule?.memo ?? ""
                
                #if DEBUG
                print("ScheduleBindings, memo, GET: scheduleUID=\(scheduleUID), value='\(value)'")
                #endif
                
                return value
            },
            set: { [weak vm] newValue in
                guard let vm = vm else { return }
                
                #if DEBUG
                print("ScheduleBindings, memo, SET: scheduleUID=\(scheduleUID), newValue='\(newValue)'")
                #endif
                
                if let schedule = vm.selectedSchedule {
                    vm.scheduleCRUD.updateScheduleInfo(
                        uid: schedule.uid,
                        title: schedule.title,
                        memo: newValue,
                        dDay: schedule.d_day
                    )
                }
                
                #if DEBUG
                print("ScheduleBindings, memo, AFTER_SET: 메모 업데이트 요청 완료")
                #endif
            }
        )
    }
    
    func dDay(scheduleUID: String) -> Binding<Date> {
        guard let vm = vm else { return .constant(Date()) }
        
        return Binding(
            get: { [weak vm] in
                guard let vm = vm else { return Date() }
                let value = vm.selectedSchedule?.d_day ?? Date()
                
                #if DEBUG
                print("ScheduleBindings, dDay, GET: scheduleUID=\(scheduleUID), value='\(value)'")
                #endif
                
                return value
            },
            set: { [weak vm] newValue in
                guard let vm = vm else { return }
                
                #if DEBUG
                print("ScheduleBindings, dDay, SET: scheduleUID=\(scheduleUID), newValue='\(newValue)'")
                #endif
                
                if let schedule = vm.selectedSchedule {
                    vm.scheduleCRUD.updateScheduleInfo(
                        uid: schedule.uid,
                        title: schedule.title,
                        memo: schedule.memo,
                        dDay: newValue
                    )
                }
                
                #if DEBUG
                print("ScheduleBindings, dDay, AFTER_SET: D-Day 업데이트 요청 완료")
                #endif
            }
        )
    }
    
    /**
     * 선택된 스케줄 바인딩
     */
    var selectedSchedule: Binding<ScheduleModel?> {
        guard let vm = vm else { return .constant(nil) }
        
        return Binding(
            get: { [weak vm] in
                vm?.selectedSchedule
            },
            set: { [weak vm] newValue in
                vm?.selectedSchedule = newValue
            }
        )
    }
}
