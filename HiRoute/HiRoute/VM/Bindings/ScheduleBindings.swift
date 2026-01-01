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
    
    /**
     * 제목 바인딩
     */
    var title: Binding<String> {
        guard let vm = vm else { return .constant("") }
        
        return Binding(
            get: {
                vm.selectedSchedule?.title ?? ""
            },
            set: { newValue in
                guard let schedule = vm.selectedSchedule else { return }
                vm.updateScheduleInfo(uid: schedule.uid, title: newValue, memo: schedule.memo, dDay: schedule.d_day)
            }
        )
    }
    
    /**
     * 메모 바인딩
     */
    var memo: Binding<String> {
        guard let vm = vm else { return .constant("") }
        
        return Binding(
            get: {
                vm.selectedSchedule?.memo ?? ""
            },
            set: { newValue in
                guard let schedule = vm.selectedSchedule else { return }
                vm.updateScheduleInfo(uid: schedule.uid, title: schedule.title, memo: newValue, dDay: schedule.d_day)
            }
        )
    }
    
    /**
     * D-Day 바인딩
     */
    var dDay: Binding<Date> {
        guard let vm = vm else { return .constant(Date()) }
        
        return Binding(
            get: {
                vm.selectedSchedule?.d_day ?? Date()
            },
            set: { newValue in
                guard let schedule = vm.selectedSchedule else { return }
                vm.updateScheduleInfo(uid: schedule.uid, title: schedule.title, memo: schedule.memo, dDay: newValue)
            }
        )
    }
}
