//
//  Persistence.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

/// Schedule 관련 양방향 바인딩 컨테이너
/// SET은 메모리만 업데이트. 실제 DB/서버 저장은 "저장" 버튼 클릭 시 별도 호출.
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

                vm.updateUiTitle(newValue)

                #if DEBUG
                print("ScheduleBindings, title, AFTER_SET: 제목 업데이트 완료")
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

                vm.updateUiMemo(newValue)

                #if DEBUG
                print("ScheduleBindings, memo, AFTER_SET: 메모 업데이트 완료")
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

                vm.updateUiDDay(newValue)

                #if DEBUG
                print("ScheduleBindings, dDay, AFTER_SET: D-Day 업데이트 완료")
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
