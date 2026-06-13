//
//  PlanEvent.swift
//  HiRoute
//
//  Created by Jupond on 2/26/26.
//

import SwiftUI

/// PlanView 계층에서 발생하는 사용자 이벤트를 중앙 관리하는 구조체.
///
/// ## 도입 배경 (Prop Drilling 제거)
/// 기존 PlanView → PlanBottomSection → TimeLineListView/PlanMapView로
/// `onClickCell`, `onClickAnnotation` 콜백이 릴레이되고 있었다.
/// 이 콜백들은 모두 "Plan을 선택한다"는 동일한 동작이었으므로
/// PlanEvent.selectPlan() 하나로 통합하여 Prop Drilling을 제거했다.
///
/// ## 설계 원칙
/// - PlaceEvent와 동일한 패턴: struct + weak var vm
/// - struct: 스택 할당, ARC 오버헤드 없음
/// - weak var: ScheduleVM에 대한 약한 참조, 순환 참조 방지
///
/// ## 데이터 흐름
/// 1. TimeLineListView 셀 클릭 → scheduleVM.planEvent.selectPlan(planModel)
/// 2. PlanEvent가 scheduleVM.currentPlanModel에 값 할당
/// 3. 호출 측에서 navigationVM.navigateTo(.place) 호출하여 PlaceView로 전환
///
/// ## 확장 예정
/// 추후 Plan 관련 UI 이벤트(드래그 정렬, 삭제 확인 등)가 추가될 예정.
/// 현재는 selectPlan 하나이지만 별도 파일로 분리한 이유.
struct PlanEvent {

    /// ScheduleVM에 대한 약한 참조.
    /// - weak: PlanEvent가 ScheduleVM의 수명을 연장하지 않음 (retain cycle 방지)
    /// - private: 외부에서 직접 VM에 접근 불가 (캡슐화)
    private weak var vm: ScheduleVM?

    init(vm: ScheduleVM) {
        self.vm = vm
    }

    /// Plan 선택 이벤트 (타임라인 셀 클릭 / 지도 어노테이션 클릭 시 호출)
    /// - Parameter planModel: 선택된 Plan 모델
    /// - Note: ScheduleVM.currentPlanModel에 값을 할당. 화면 전환은 호출 측에서 navigateTo()로 처리.
    func selectPlan(_ planModel: PlanModel) {
        vm?.currentPlanModel = planModel
    }
}
