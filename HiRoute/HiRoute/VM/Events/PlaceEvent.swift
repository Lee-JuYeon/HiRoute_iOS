//
//  PlaceEvent.swift
//  HiRoute
//
//  Created by Jupond on 2/26/26.
//

import SwiftUI

/// PlaceView 계층에서 발생하는 모든 사용자 이벤트를 중앙 관리하는 구조체.
///
/// ## 도입 배경 (Prop Drilling 제거)
/// 기존에는 PlaceView → PlaceTopSection → PlaceButtons 등으로
/// 클로저 콜백이 3~4단계 릴레이되는 "Prop Drilling" 문제가 있었다.
/// 예: `onClickSearchRoute`, `onClickBookMark`, `onClickCopyAddress` 등
/// 총 19개의 콜백이 중간 뷰를 단순 경유하며 전달되고 있었다.
///
/// ## 설계 원칙
/// - **struct**: 스택 할당. ARC 오버헤드 없음. 힙 할당/참조 카운팅 비용 제로.
/// - **weak var vm**: PlaceVM(class)에 대한 약한 참조. 순환 참조(retain cycle) 방지.
///   PlaceVM이 해제되면 vm은 자동으로 nil이 되어 메모리 누수 없음.
/// - **Optional chaining (vm?.xxx)**: VM이 이미 해제된 경우 안전하게 무시.
///   크래시 없이 graceful 처리.
///
/// ## 기존 PlanBindings 패턴과 동일한 구조
/// PlanBindings(struct + weak var vm)와 동일한 패턴을 따름.
/// Bindings는 양방향 데이터 바인딩, Event는 단방향 이벤트 발신 역할.
///
/// ## 하위 뷰에서의 사용법
/// 하위 뷰는 `@EnvironmentObject private var placeVM: PlaceVM`을 선언하고,
/// `placeVM.events.searchRoute()` 형태로 이벤트를 발생시킨다.
/// 중간 뷰(섹션뷰)를 거치지 않고 직접 VM에 도달하므로 콜백 릴레이가 불필요.
struct PlaceEvent {

    /// PlaceVM에 대한 약한 참조.
    /// - weak: PlaceEvent가 PlaceVM의 수명을 연장하지 않음 (retain cycle 방지)
    /// - private: 외부에서 직접 VM에 접근하지 못하도록 캡슐화
    private weak var vm: PlaceVM?

    init(vm: PlaceVM) {
        self.vm = vm
    }

    // MARK: - Sheet Triggers (시트/풀스크린 열기)
    // 각 메서드는 PlaceVM의 @Published Bool 트리거를 true로 변경한다.
    // PlaceView에서 해당 @Published를 $바인딩으로 시트에 연결하고 있으므로,
    // 트리거가 true가 되면 시트가 자동으로 표시된다.

    /// 정보 수정 요청 시트 열기 (PlaceInfoEditRequestView에서 호출)
    func editInfo() {
        vm?.showEditInfoView = true
    }

    /// 일정에 장소 추가 바텀시트 열기 (PlaceButtons에서 호출)
    func addPlace() {
        vm?.showAddScheduleView = true
    }

    // MARK: - Snackbar Triggers (스낵바 표시)

    /// 주소 복사 후 스낵바 표시 (PlaceAddressView에서 호출)
    /// - Parameter address: 클립보드에 복사할 주소 문자열
    func copyAddress(_ address: String) {
        UIPasteboard.general.string = address
        vm?.showSnackBarCopyAddress = true
    }

    // MARK: - Actions (비즈니스 로직 실행)

    /// 북마크 토글 (PlaceButtons에서 호출)
    /// - Parameter place: 북마크 대상 장소 모델
    /// - Note: VM 내부에서 서버 API 호출 후 결과에 따라 스낵바 표시
    func toggleBookMark(_ place: PlaceModel) {
        vm?.toggleBookmark(for: place)
    }

    /// 정보 수정 요청 제출 (현재는 비짓서울-only라 미지원 처리)
    /// - Parameters:
    ///   - text: 수정 요청 텍스트
    ///   - userUid: 요청자 유저 UID
    ///   - placeUid: 대상 장소 UID
    /// - Note: 시트를 닫고(showEditInfoView = false) VM의 처리로 넘김
    func submitEditInfo(text: String, userUid: String, placeUid: String) {
        vm?.showEditInfoView = false
        vm?.editInfoRequest(text: text, userUid: userUid, placeUid: placeUid)
    }

    /// 정보 수정 요청 취소 (PlaceView의 topSheet 내 "취소" 버튼에서 호출)
    /// - Note: 시트만 닫음. 서버 호출 없음.
    func cancelEditInfo() {
        vm?.showEditInfoView = false
    }

    // MARK: - Useful Actions

    /// 도움돼요 토글 (ReviewCell에서 호출)
    /// - Parameter reviewUid: 대상 리뷰 UID
    func toggleUseful(reviewUid: String) {
        vm?.toggleUseful(reviewUid: reviewUid)
    }

    // MARK: - Review Actions

    /// 리뷰 신고 (ReviewCell → SheetReviewCellOptionView에서 호출)
    /// - Parameters:
    ///   - reviewUid: 신고 대상 리뷰 UID
    ///   - reportType: 신고 사유 (ReportType.displayText)
    func reportReview(reviewUid: String, reportType: String) {
        vm?.reportReview(reviewUid: reviewUid, reportType: reportType)
    }
}
