//
//  EmergencyView.swift
//  HiRoute
//
//  Created by Jupond on 3/10/26.
//

import SwiftUI
import MapKit

struct EmergencyView: View {

    @EnvironmentObject private var naviVM: NavigationVM
    @EnvironmentObject private var placeVM: PlaceVM

    // MARK: - State
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @State private var selectedCategory: EmergencyCategory = .emergencyRoom

    // MARK: - Emergency Categories
    enum EmergencyCategory: String, CaseIterable {
        case emergencyRoom = "응급실"
        case pharmacy = "약국"
        case hospital = "병원"
        case subwayMap = "노선도"

        var icon: String {
            switch self {
            case .emergencyRoom: return "cross.circle.fill"
            case .pharmacy: return "staroflife.fill"
            case .hospital: return "building.fill"
            case .subwayMap: return "tram.fill"
            }
        }

        var placeType: PlaceType? {
            switch self {
            case .emergencyRoom: return .hospital
            case .pharmacy: return .pharmacy
            case .hospital: return .hospital
            case .subwayMap: return nil
            }
        }
    }

    // MARK: - Filtered Places
    private var filteredPlaces: [PlaceModel] {
        guard let targetType = selectedCategory.placeType else { return [] }
        return placeVM.places.filter { $0.type == targetType }
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // 긴급 전화 버튼
            emergencyCallSection

            // 카테고리 필터
            categoryFilterSection

            // 메인 콘텐츠
            if selectedCategory == .subwayMap {
                subwayMapPlaceholder
            } else {
                emergencyMapSection
            }
        }
        .background(Color.getColour(.background_white))
    }

    // MARK: - Emergency Call Section
    private var emergencyCallSection: some View {
        HStack(spacing: 12) {
            emergencyCallButton(
                number: "119",
                label: "소방/응급",
                color: .red
            )
            emergencyCallButton(
                number: "112",
                label: "경찰",
                color: .blue
            )
            emergencyCallButton(
                number: "1339",
                label: "의료상담",
                color: .green
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.getColour(.background_alternative))
    }

    private func emergencyCallButton(number: String, label: String, color: Color) -> some View {
        Button(action: {
            if let url = URL(string: "tel://\(number)") {
                UIApplication.shared.open(url)
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                Text(number)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(12)
        }
    }

    // MARK: - Category Filter Section
    private var categoryFilterSection: some View {
        HStack(spacing: 8) {
            ForEach(EmergencyCategory.allCases, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: category.icon)
                            .font(.system(size: 12))
                        Text(category.rawValue)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        selectedCategory == category
                            ? Color.getColour(.label_strong)
                            : Color.getColour(.background_alternative)
                    )
                    .foregroundColor(
                        selectedCategory == category
                            ? Color.getColour(.background_white)
                            : Color.getColour(.label_normal)
                    )
                    .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Emergency Map Section
    private var emergencyMapSection: some View {
        ZStack(alignment: .bottom) {
            // 지도
            Map(coordinateRegion: $mapRegion,
                showsUserLocation: true,
                annotationItems: filteredPlaces
            ) { place in
                MapAnnotation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: place.address.lat ?? 0,
                        longitude: place.address.lon ?? 0
                    )
                ) {
                    VStack(spacing: 2) {
                        Image(systemName: selectedCategory.icon)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                        Text(place.title)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.getColour(.label_strong))
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 하단 장소 리스트
            if !filteredPlaces.isEmpty {
                emergencyPlaceList
            }
        }
    }

    // MARK: - Emergency Place List
    private var emergencyPlaceList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filteredPlaces, id: \.uid) { place in
                    emergencyPlaceCard(place)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
            Color.getColour(.background_white)
                .opacity(0.95)
                .cornerRadius(16, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
        )
    }

    private func emergencyPlaceCard(_ place: PlaceModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.getColour(.label_strong))
                .lineLimit(1)

            Text(place.address.fullAddress ?? "")
                .font(.system(size: 11))
                .foregroundColor(Color.getColour(.label_assistive))
                .lineLimit(2)

            if let subtitle = place.subtitle {
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(Color.getColour(.label_neutral))
            }
        }
        .padding(12)
        .frame(width: 200, alignment: .leading)
        .background(Color.getColour(.background_white))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .onTapGesture {
            // 지도 중심을 해당 장소로 이동
            mapRegion.center = CLLocationCoordinate2D(
                latitude: place.address.lat,
                longitude: place.address.lon
            )
            mapRegion.span = MKCoordinateSpan(
                latitudeDelta: 0.005, longitudeDelta: 0.005
            )
        }
    }

    // MARK: - Subway Map Placeholder
    private var subwayMapPlaceholder: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tram.fill")
                .font(.system(size: 48))
                .foregroundColor(Color.getColour(.label_assistive))
            Text("서울 지하철 노선도")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.getColour(.label_strong))
            Text("노선도 및 길찾기 기능 준비 중")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_neutral))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Corner Radius Helper (iOS 14 compatible)
private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

private struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
