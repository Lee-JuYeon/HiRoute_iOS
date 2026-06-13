//
//  BookmarkChange.swift
//  HiRoute
//
//  Created by Jupond on 7/29/25.
//
import SwiftUI

/// 장소 상세 화면 (PlaceTopSection + PlaceBottomSection + 시트/풀스크린)
///
/// ## Event 패턴 적용 후 변경 요약
///
/// ### 제거된 것들:
/// [변경 전] 9개의 @State 시트/스낵바 트리거 + 6개의 private func 콜백이 존재.
///   이 콜백들은 하위 뷰에 전달되어 3~4단계 Prop Drilling을 형성.
///   총 19개의 콜백 파라미터가 뷰 계층을 따라 릴레이됨.
///
/// [변경 후]
///   - 9개 @State 트리거 → PlaceVM @Published로 이동
///   - 6개 콜백 함수 → PlaceEvent 메서드로 대체
///   - 하위 뷰 호출 시 콜백 파라미터 모두 제거
///
/// ### 유지된 것들:
/// - @State editInfoText: 텍스트 입력 필드의 바인딩용. 매 키 입력마다 변경되므로
///   @Published로 옮기면 모든 @EnvironmentObject 구독 뷰가 매번 body 재평가.
///   따라서 이 뷰 로컬 @State로 유지하여 이 뷰만 재평가되도록 제한.
///
/// ### 시트 바인딩:
/// - .topSheet(isOpen: $placeVM.showEditInfoView)
/// - .bottomSheet(isOpen: $placeVM.showAddScheduleView)
///   PlaceVM의 @Published Bool에 바인딩.
///
/// ### navigateTo 기반 화면 전환:
/// - searchRoute, pictureList, reviewWrite → navigationVM.navigateTo()로 전환.
///
/// ### 라이프사이클 리셋 (.onDisappear):
/// @Published 트리거(showEditInfoView, showAddScheduleView)는
/// VM이 메모리에 살아있는 한 값이 유지되므로,
/// 뷰가 사라질 때 수동으로 false 리셋 필수.
struct PlaceView : View {

    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var navigationVM : NavigationVM
    @EnvironmentObject private var scheduleVM : ScheduleVM
    /// PlaceVM: 시트/스낵바 트리거(@Published) + 이벤트(events) 모두 보유.
    /// 이 뷰에서 $placeVM.showXxx 형태로 시트 바인딩에 사용.
    @EnvironmentObject private var placeVM : PlaceVM
    @EnvironmentObject private var localVM : LocalVM
    @EnvironmentObject private var userVM : UserVM

    /// 정보 수정 요청 텍스트 입력값.
    /// @Published가 아닌 @State로 유지하는 이유:
    /// 매 키 입력마다 값이 변경되므로 @Published로 하면
    /// PlaceVM을 구독하는 모든 하위 뷰가 body 재평가됨 (성능 저하).
    /// @State는 이 뷰의 body만 재평가하므로 고빈도 입력에 적합.
    @State private var editInfoText : String = ""
    @State private var showMemoSheet : Bool = false
    @State private var memoText : String = ""

    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
        navigationVM.goBack()
    }

    var body: some View {
        if let planModel = scheduleVM.currentPlanModel {
            VStack {
                HStack {
                    ImageButton(
                        imageUrl: "icon_back",
                        imageSize: 30
                    ) {
                        dismissView()
                    }

                    Spacer()
                }
                .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))


                ScrollView(.vertical) {
                    VStack(alignment: HorizontalAlignment.leading, spacing: 0){
                        // [Event 패턴 적용 후] 콜백 파라미터 없이 데이터만 전달.
                        // 하위 뷰들은 @EnvironmentObject로 PlaceVM에 직접 접근.
                        PlaceTopSection(
                            setPlaceModel: planModel.placeModel
                        )

                        PlaceBottomSection(
                            setPlanModel: planModel,
                            setNationalityType: localVM.nationality,
                            setPlaceModeType: navigationVM.currentPlaceModeType,
                            setModeType: $navigationVM.currentModeType,
                            onClickMemo: {
                                memoText = planModel.memo
                                showMemoSheet = true
                            }
                        )
                    }
                }
                .background(Color.getColour(.background_yellow_white))
            }
        // [Event 패턴] PlaceVM의 @Published Bool에 바인딩하여 시트 제어.
        // 하위 뷰에서 placeVM.events.editInfo() 호출 시 showEditInfoView = true → 시트 열림.
        .topSheet(isOpen: $placeVM.showEditInfoView) {
            // 정보 수정 제안
            SheetTextFieldView(
                setHint: "어떤 정보를 수정요청 하고 싶으신가요?",
                setText: $editInfoText,
                setToolBarTitle: "정보 수정 요청",
                callBackCancel: {
                    placeVM.events.cancelEditInfo() // [Event] 시트 닫기 (showEditInfoView = false)
                    editInfoText = ""

                    // 약간의 딜레이 후 키보드 해제
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        hideKeyboard()
                    }
                },
                callBackSave: {
                    // [Event] 서버에 수정 요청 전송 + 시트 닫기
                    placeVM.events.submitEditInfo(
                        text: editInfoText,
                        userUid: userVM.currentUserUID,
                        placeUid: planModel.placeModel.uid
                    )
                    editInfoText = ""

                    // 약간의 딜레이 후 키보드 해제
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        hideKeyboard()
                    }
                }
            )

        }
        .topSheet(isOpen: $showMemoSheet) {
            SheetTextFieldView(
                setHint: "장소에 대한 메모를 입력하세요",
                setText: $memoText,
                setToolBarTitle: "메모",
                callBackCancel: {
                    showMemoSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        hideKeyboard()
                    }
                },
                callBackSave: {
                    if let planModel = scheduleVM.currentPlanModel {
                        // UI-only(updateUiPlanMemo) 대신 서버+DB 영속화(updatePlanMemo) 호출.
                        // 기존 updateUiPlanMemo는 selectedSchedule 가드 + 메모리만 변경이라 저장 안 됨.
                        scheduleVM.updatePlanMemo(planUID: planModel.uid, newMemo: memoText)
                    }
                    showMemoSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        hideKeyboard()
                    }
                }
            )
        }
        .bottomSheet(isOpen: $placeVM.showAddScheduleView) {
            AddPlaceAtScheduleView(
                placeToAdd: planModel.placeModel,
                onComplete: {
                    placeVM.showAddScheduleView = false
                }
            )
        }
        .snackbar($placeVM.showSnackBarAddPlace, message: "일정에 추가되었습니다")
        // [Event 패턴] 스낵바도 PlaceVM의 @Published Bool에 바인딩.
        // PlaceEvent.copyAddress() 등에서 트리거 → 스낵바 자동 표시.
        .snackbar($placeVM.showSnackBarAddBookMark, message: "북마크가 추가되었습니다.")
        .snackbar($placeVM.showSnackBarRemoveBookMark, message: "북마크가 해제되었습니다")
        .snackbar($placeVM.showSnackBarCopyAddress, message: "주소지가 클립보드에 저장되었어요 :)")
        .snackbar($placeVM.showSnackBarReportReview, message: "감사합니다, 검토해볼께요!")
        .snackbar($placeVM.showSnackBarNoImage, message: "준비된 이미지가 없습니다.")
        .onDisappear {
            placeVM.showEditInfoView = false
            placeVM.showAddScheduleView = false
            placeVM.showSnackBarAddPlace = false
            placeVM.showSnackBarNoImage = false
            showMemoSheet = false
        }
        } // if let planModel
    }
}

