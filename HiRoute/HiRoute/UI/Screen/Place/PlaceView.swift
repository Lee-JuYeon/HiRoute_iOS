//
//  BookmarkChange.swift
//  HiRoute
//
//  Created by Jupond on 7/29/25.
//
import SwiftUI

struct PlaceView : View {
    
    private var getVisitPlaceModel : PlanModel
    private var getPlaceModeType : PlaceModeType
    @Binding private var getModeType : ModeType
    init(
        setPlanModel : PlanModel,
        setPlaceModeType : PlaceModeType,
        setModeType : Binding<ModeType>
    ){
        self.getVisitPlaceModel = setPlanModel
        self.getPlaceModeType = setPlaceModeType
        self._getModeType = setModeType
    }
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var scheduleVM: ScheduleVM
    @EnvironmentObject private var placeVM: PlaceVM
    @EnvironmentObject private var localVM : LocalVM

    // 오프라인 상태 관리
    @State private var isOfflineMode: Bool = false
    
    
    /// ✅ 추가: 장소 정보 편집 제안
    private func handleEditPlaceInfo(_ placeUID: String) {
        if isOfflineMode {
            // 오프라인 모드에서는 로컬에 저장 후 나중에 동기화
//            placeVM.queueOfflineEditRequest(placeUID)
        } else {
//            placeVM.requestPlaceEdit(placeUID)
        }
    }
    
    /// ✅ 추가: 북마크 토글 처리
    private func handleBookmarkToggle(_ placeUID: String) {
//        placeVM.toggleBookmark(placeUID: placeUID)
    }
    
    /// ✅ 추가: 네비게이션 처리 (오프라인 대응)
    private func handleNavigation(_ address: AddressModel) {
        let latitude = address.addressLat
        let longitude = address.addressLon
        let urlString = "maps://?q=\(latitude),\(longitude)"
        
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    /// ✅ 추가: 스케줄에 장소 추가
    private func handleAddPlaceToSchedule(_ place: PlaceModel) {
//        scheduleVM.addPlaceToCurrentSchedule(place)
    }
    
    /// ✅ 추가: 리뷰 상세보기
    private func handleReviewDetail(_ review: ReviewModel) {
//        placeVM.selectReview(review)
    }
    
    /// ✅ 추가: 리뷰 작성
    private func handleWriteReview(_ placeUID: String) {
//        placeVM.startReviewComposition(for: placeUID)
    }
    
    /// ✅ 추가: 네트워크 상태 확인
    private func checkNetworkStatus() {
        // 네트워크 상태 확인 로직
//        isOfflineMode = !NetworkMonitor.shared.isConnected
    }
    
    /// ✅ 추가: 장소 상세 정보 로드 (캐시 우선)
    private func loadPlaceDetails() {
//        placeVM.loadPlaceDetails(placeUID: getVisitPlaceModel.placeModel.uid)
    }
    
    
    @ViewBuilder
    private func backButton() -> some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image("icon_arrow")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .foregroundColor(Color.getColour(.label_normal))
                .frame(width: 20, height: 20)
        }
        .frame(width: 44, height: 44) // ✅ 터치 영역 확장
        .contentShape(Rectangle()) // ✅ 전체 영역을 터치 가능하게
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
    }
    
    var body: some View {
        VStack {
            HStack(alignment:.center, spacing: 0) {
                backButton()
                Spacer()
                
                // 오프라인 인디케이터
                if isOfflineMode {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.orange)
                        .padding(.trailing, 16)
                }
            }
            
            
            ScrollView(.vertical) {
                VStack(alignment: HorizontalAlignment.leading, spacing: 0){
                    PlaceTopSection(
                        setPlaceModel: getVisitPlaceModel.placeModel,
                        onCallBackEditInfo: { placeUID in
                            // PlaceVM을 통한 정보 변경 제안하기 뷰
                            handleEditPlaceInfo(placeUID)
                        },
                        onCallBackCopyAddress: { addressModel in
                            // 주소 클립보드 복사
                            UIPasteboard.general.string = addressModel.fullAddress
                        },
                        onCallBackBookMark: { bookMarkedUID in
                            // PlaceVM을 통한 북마크 추가/삭제
                            handleBookmarkToggle(bookMarkedUID)
                        },
                        onCallBackNavigate: { addressModel in
                            // 길찾기
                            handleNavigation(addressModel)
                        },
                        onCallBackAddPlace: { placeModel in
                            // cheduleVM을 통한 일정에 place추가
                            handleAddPlaceToSchedule(placeModel)
                        }
                    )
                    
                    PlaceBottomSection(
                        setVisitPlaceModel: getVisitPlaceModel,
                        setNationalityType: localVM.nationality,
                        setPlaceModeType: getPlaceModeType,
                        setModeType: $getModeType,
                        onClickReviewCell: { reviewModel in
                            // PlaceVM을 통한 리뷰 셀 클릭이벤트
                            handleReviewDetail(reviewModel)
                        },
                        onCallBackWriteReview: { placeUID in
                            // PlaceVM을 통한 리뷰 작성뷰로 이동
                            handleWriteReview(placeUID)
                        }
                    )
                }
            }
            .background(Color.getColour(.background_yellow_white))
        }
        .onAppear {
            // ✅ 추가: 오프라인 상태 감지
            checkNetworkStatus()
            // ✅ 추가: 장소 상세 정보 로드 (캐시 우선)
            loadPlaceDetails()
        }
    }
}
