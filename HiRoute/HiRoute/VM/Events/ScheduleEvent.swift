//
//  ScheduleEvent.swift
//  HiRoute
//
//  Created by Jupond on 3/1/26.
//

import SwiftUI

/// ScheduleView 계층에서 발생하는 사용자 이벤트를 중앙 관리하는 구조체.
///
/// ## 설계 원칙
/// - PlaceEvent, PlanEvent와 동일한 패턴: struct + weak var vm
/// - struct: 스택 할당, ARC 오버헤드 없음
/// - weak var: ScheduleVM에 대한 약한 참조, 순환 참조 방지
///
/// ## 데이터 흐름
/// ScheduleCell에서 scheduleVM.scheduleEvent.selectSchedule(model) 직접 호출
/// → 콜백 릴레이 불필요
struct ScheduleEvent {

    private weak var vm: ScheduleVM?

    init(vm: ScheduleVM) {
        self.vm = vm
    }

    func selectSchedule(_ schedule: ScheduleModel) {
        vm?.selectSchedule(schedule)
    }

    func deleteSchedule(_ scheduleUID: String) {
        vm?.deleteSchedule(scheduleUID: scheduleUID)
    }
}
