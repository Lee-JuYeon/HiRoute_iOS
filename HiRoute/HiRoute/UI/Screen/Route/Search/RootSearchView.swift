//
//  Persistence.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Foundation
import Combine


struct RootSearchView: View {
   
    @EnvironmentObject private var planVM : PlanViewModel
    @EnvironmentObject private var naviVM : NavigationVM
    @StateObject private var searchVM = SearchViewModel()

    @ViewBuilder
    private func searchTopBar(
        onBack : @escaping () -> Void,
        onSearch : @escaping (String) -> Void
    ) -> some View {
        HStack(
            alignment: VerticalAlignment.center
        ){
            Image("icon_arrow_right")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .scaleEffect(x: -1, y: 1) // 수평 반전
                .foregroundColor(Color.getColour(.label_strong))
                .frame(
                    width: 24,
                    height: 24
                )
                .onTapGesture {
                    onBack()
                }
            
            TextField("추가하고 싶은 장소 검색", text: $planVM.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(1)
                .frame(
                    maxWidth: .infinity
                )
            
            Image("icon_search")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .foregroundColor(Color.getColour(.label_strong))
                .frame(
                    width: 24,
                    height: 24
                )
                .onTapGesture {
                    onSearch(planVM.searchText)
                }
        }
    }
    

    var body: some View {
        VStack(
            alignment : HorizontalAlignment.leading
        ){
            searchTopBar(
                onBack: {
                    naviVM.navigateTo(setDestination: .planDetail)
                },
                onSearch: { searchText in
                    // 여기서 텍스트 검색 로직 구현
                }
            )
            
            // 업소 리스트 (조건부 표시)
            if searchVM.showStoreList {
                StoreListView(
                    stores: searchVM.stores,
                    onStoreSelect: { store in
                        searchVM.selectStore(store)
                    },
                    onClose: {
                        searchVM.hideStoreList()
                    }
                )
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            
            CustomMapView(searchVM: searchVM)
        }
    }
}


struct CustomMapView : View {
    
    @ObservedObject var searchVM: SearchViewModel

    
    /*
     CLLocationCoordinate2D : 위도 경도를 나타내는 구조체, 지구상의 특정 위치를 표현
     MKCoordinateSpan : 지도에서 보여줄 범위 (확대/축소정도)를 나타내는 구조체
     center : 지도의 중심점, 지도가 처음 로드될 때 화면 중앙에 표시될 위치
     span : 지도의 표시 범위,MKCoordinateSpan타입으로 지정, 지도에서 얼마나 넓은 영역을 보여줄지 경정
     */
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), // 위도 경도를 나타내는 구조체
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    
    @StateObject private var openAPIvm = OpenAPIVM()
    @StateObject private var locationManager = LocationManager()

    @State private var hasInitializedLocation = false
    @State private var selectedStore: Store?

    
    // 중앙 핀의 위도경도 (지도 중심과 동일)
    @State private var centerPinCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
 
   
    
    
    @ViewBuilder
    private func mapView() -> some View {
        Map(coordinateRegion: $region,
            showsUserLocation: true,
            annotationItems: openAPIvm.storeMarkers) { storeMarker in
            MapAnnotation(coordinate: storeMarker.coordinate) {
                Button(action: {
                    selectedStore = storeMarker.store
                }) {
                    Image(systemName: "mappin")
                        .font(.title3)
                        .foregroundColor(.red)
                        .shadow(radius: 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onAppear {
            searchVM.requestLocationPermission()
        }
    }
    
    @ViewBuilder
    private func centerPin() -> some View {
        VStack {
            Image(systemName: "mappin.and.ellipse")
                .font(.title)
                .foregroundColor(.red)
                .shadow(radius: 3)
            
            // 위도경도 정보 표시
            VStack(spacing: 2) {
                Text("위도: \(String(format: "%.6f", centerPinCoordinate.latitude))")
                    .font(.caption)
                    .foregroundColor(.black)
                Text("경도: \(String(format: "%.6f", centerPinCoordinate.longitude))")
                    .font(.caption)
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
            .shadow(radius: 2)
        }
        .allowsHitTesting(false) // 터치 이벤트가 지도로 전달되도록 함
    }
    
    @ViewBuilder
    private func circleView() -> some View {
        if #available(iOS 17.0, *) {
            // iOS 17 이상 - 새로운 스타일 적용
            Circle()
                .stroke(Color.red.opacity(0.7), style: StrokeStyle(lineWidth: 3, dash: [5, 3]))
                .fill(Color.red.opacity(0.15))
                .frame(width: getCircleSize(), height: getCircleSize())
                .shadow(color: Color.red.opacity(0.3), radius: 2, x: 0, y: 0)
                .allowsHitTesting(false)
        } else {
            // iOS 17 미만 - 기본 스타일
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                Circle()
                    .stroke(Color.red.opacity(0.6), lineWidth: 2)
            }
            .frame(width: getCircleSize(), height: getCircleSize())
            .allowsHitTesting(false)
        }
    }

    // 50미터를 화면 크기로 변환하는 함수
    private func getCircleSize() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let latitudeDeltaInMeters = region.span.latitudeDelta * 111000 // 위도 1도 ≈ 111km
        let metersPerPixel = latitudeDeltaInMeters / Double(screenHeight)
        let radiusInPixels = 100.0 / metersPerPixel
        return CGFloat(radiusInPixels * 2) // 지름이므로 2배
    }
       
    @ViewBuilder
    private func callButton(onCallAPI : @escaping () -> Void) -> some View {
        // 상단 중앙 정렬
        VStack {
            HStack {
                Spacer()
                
                Button {
                    onCallAPI()
                } label: {
                    HStack {
                        if openAPIvm.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        }
                        Text(openAPIvm.isLoading ? "검색 중..." : "🔄 주변 장소 검색하기")
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                            .fontWeight(.bold)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(openAPIvm.isLoading ? Color.gray : Color.black)
                    )
                }
                .disabled(openAPIvm.isLoading)
                
                Spacer()
            }
            .padding(.top, 60)  // SafeArea 고려한 상단 여백
            
            Spacer()
        }
    }
    
    
    // 업소 정보 표시 바텀시트
    @ViewBuilder
    private func storeDetailSheet() -> some View {
        if let store = selectedStore {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.bizesNm)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if let branchName = store.brchNm, !branchName.isEmpty {
                            Text(branchName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button("닫기") {
                        selectedStore = nil
                    }
                    .foregroundColor(.blue)
                }
                
                Text(store.indsSclsNm)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
                
                if let address = store.rdnmAdr ?? store.lnoAdr {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding()
        }
    }
    
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                ZStack {
                    mapView()
                    circleView()
                    centerPin()
                    callButton {
                        openAPIvm.fetchNearbyStores(center: centerPinCoordinate)
                    }
                }
            }
            
            // 바텀시트
            if selectedStore != nil {
                VStack {
                    Spacer()
                    storeDetailSheet()
                }
            }
        }
        .alert(isPresented: .constant(openAPIvm.errorMessage != nil)) {
            if #available(iOS 15.0, *) {
                // iOS 15 이상에서는 title과 message 지원
                Alert(
                    title: Text("오류"),
                    message: Text(openAPIvm.errorMessage ?? "알 수 없는 오류가 발생했습니다."),
                    dismissButton: .default(Text("확인")) {
                        openAPIvm.errorMessage = nil
                    }
                )
            } else {
                // iOS 14 이하에서는 기본 Alert 사용
                Alert(
                    title: Text("오류"),
                    message: Text(openAPIvm.errorMessage ?? "알 수 없는 오류가 발생했습니다."),
                    dismissButton: .default(Text("확인")) {
                        openAPIvm.errorMessage = nil
                    }
                )
            }
        }
    }
}
