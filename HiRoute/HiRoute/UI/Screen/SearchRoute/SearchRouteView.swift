//
//  SearchRouteView.swift
//  HiRoute
//
//  Created by Jupond on 3/6/26.
//

import SwiftUI
import CoreLocation
import MapKit

// MARK: - 서울 대중교통환승경로 API 응답 모델

private struct SeoulRouteResponse: Decodable {
    let msgHeader: SeoulMsgHeader?
    let msgBody: SeoulMsgBody?
}

private struct SeoulMsgHeader: Decodable {
    let headerCd: String?
    let headerMsg: String?
    let itemCount: Int?
}

private struct SeoulMsgBody: Decodable {
    let itemList: [SeoulRouteItem]

    enum CodingKeys: String, CodingKey {
        case itemList
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let array = try? container.decode([SeoulRouteItem].self, forKey: .itemList) {
            itemList = array
        } else if let single = try? container.decode(SeoulRouteItem.self, forKey: .itemList) {
            itemList = [single]
        } else {
            itemList = []
        }
    }
}

private struct SeoulRouteItem: Decodable {
    let distance: Int?
    let time: Int?
    let pathList: [SeoulPathSegment]

    enum CodingKeys: String, CodingKey {
        case distance, time, pathList
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // API returns these as String ("27") or Int — handle both
        if let v = try? container.decodeIfPresent(Int.self, forKey: .distance) {
            distance = v
        } else if let s = try? container.decodeIfPresent(String.self, forKey: .distance) {
            distance = Int(s)
        } else {
            distance = nil
        }
        if let v = try? container.decodeIfPresent(Int.self, forKey: .time) {
            time = v
        } else if let s = try? container.decodeIfPresent(String.self, forKey: .time) {
            time = Int(s)
        } else {
            time = nil
        }
        if let array = try? container.decode([SeoulPathSegment].self, forKey: .pathList) {
            pathList = array
        } else if let single = try? container.decode(SeoulPathSegment.self, forKey: .pathList) {
            pathList = [single]
        } else {
            pathList = []
        }
    }
}

private struct SeoulPathSegment: Decodable {
    let routeId: String?
    let routeNm: String?
    let fid: String?
    let fname: String?
    let fx: String?
    let fy: String?
    let tid: String?
    let tname: String?
    let tx: String?
    let ty: String?
    let railLinkList: [SeoulRailLink]?
}

private struct SeoulRailLink: Decodable {
    let railLinkId: String?
}

// MARK: - TAGO API 응답 모델

private struct TAGOSubwayStation: Decodable {
    let subwayStationId: String?
    let subwayStationName: String?
    let subwayRouteName: String?
}

private struct TAGOSubwaySchedule: Decodable {
    let subwayRouteId: String?
    let subwayStationId: String?
    let subwayStationNm: String?
    let dailyTypeCode: String?
    let upDownTypeCode: String?
    let depTime: String?
    let arrTime: String?
    let endSubwayStationId: String?
    let endSubwayStationNm: String?
}

private struct TAGOBusStop: Decodable {
    let nodeid: String?
    let nodenm: String?
    let gpslati: Double?
    let gpslong: Double?
    let citycode: Int?
}

private struct TAGOBusArrival: Decodable {
    let nodeid: String?
    let nodenm: String?
    let routeid: String?
    let routeno: String?
    let arrprevstationcnt: Int?
    let arrtime: Int?
}

// MARK: - 서울 버스 도착정보 응답 모델

private struct SeoulBusArrivalResponse: Decodable {
    let msgHeader: SeoulMsgHeader?
    let msgBody: SeoulBusArrivalBody?
}

private struct SeoulBusArrivalBody: Decodable {
    let itemList: [SeoulBusArrivalItem]

    enum CodingKeys: String, CodingKey { case itemList }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let array = try? container.decode([SeoulBusArrivalItem].self, forKey: .itemList) {
            itemList = array
        } else if let single = try? container.decode(SeoulBusArrivalItem.self, forKey: .itemList) {
            itemList = [single]
        } else {
            itemList = []
        }
    }
}

private struct SeoulBusArrivalItem: Decodable {
    let stNm: String?
    let staOrd: String?
    let vehId1: String?
    let exps1: String?
}

// MARK: - TAGO 공통 응답 래퍼

private struct TAGOResponse<T: Decodable>: Decodable {
    let response: TAGOResponseBody<T>?
}

private struct TAGOResponseBody<T: Decodable>: Decodable {
    let header: TAGOHeader?
    let body: TAGOBodyWrapper<T>?
}

private struct TAGOHeader: Decodable {
    let resultCode: String?
    let resultMsg: String?
}

private struct TAGOBodyWrapper<T: Decodable>: Decodable {
    let items: TAGOItems<T>?
    let totalCount: Int?
}

private struct TAGOItems<T: Decodable>: Decodable {
    let item: [T]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let array = try? container.decode([T].self) {
            item = array
        } else if let wrapper = try? container.decode(TAGOItemWrapper<T>.self) {
            item = wrapper.item
        } else {
            item = []
        }
    }
}

private struct TAGOItemWrapper<T: Decodable>: Decodable {
    let item: [T]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let array = try? container.decode([T].self, forKey: .item) {
            item = array
        } else if let single = try? container.decode(T.self, forKey: .item) {
            item = [single]
        } else {
            item = []
        }
    }

    enum CodingKeys: String, CodingKey { case item }
}

// MARK: - Display Models

private struct RoutePoint {
    var name: String
    var lat: Double
    var lon: Double
}

private enum RouteSegmentType {
    case bus
    case subway
    case walking
}

private struct RouteSegment: Identifiable {
    let id = UUID()
    let type: RouteSegmentType
    let name: String
    let boardingName: String
    let alightingName: String
    let color: Color
    var routeId: String = ""
    var boardingLat: Double = 0
    var boardingLon: Double = 0
    var alightingLat: Double = 0
    var alightingLon: Double = 0
    var distanceMeters: Int = 0
    var estimatedMinutes: Int = 0
    var fare: Int = 0          // 세그먼트 요금 (환승 시 0)
    var fareLabel: String = "" // "기본요금", "무료환승", "-" 등
}

private struct RouteResult: Identifiable {
    let id = UUID()
    let totalTime: Int
    let totalDistance: Int
    let transferCount: Int
    let segments: [RouteSegment]
    let totalFare: Int
}

// MARK: - 지하철 노선 색상

private func subwayColor(for routeName: String) -> Color {
    switch routeName {
    case "1호선": return Color(red: 0.15, green: 0.24, blue: 0.59)
    case "2호선": return Color(red: 0.24, green: 0.70, blue: 0.29)
    case "3호선": return Color(red: 0.94, green: 0.53, blue: 0.15)
    case "4호선": return Color(red: 0.22, green: 0.64, blue: 0.86)
    case "5호선": return Color(red: 0.53, green: 0.29, blue: 0.64)
    case "6호선": return Color(red: 0.69, green: 0.46, blue: 0.27)
    case "7호선": return Color(red: 0.45, green: 0.54, blue: 0.18)
    case "8호선": return Color(red: 0.87, green: 0.28, blue: 0.45)
    case "9호선": return Color(red: 0.73, green: 0.67, blue: 0.42)
    default: return Color.getColour(.label_alternative)
    }
}

// MARK: - 버스 노선 색상

private func busColor(for routeName: String) -> Color {
    let name = routeName.trimmingCharacters(in: .whitespaces)
    // 광역(빨강): M버스, 9000번대
    if name.hasPrefix("M") || name.hasPrefix("m") {
        return Color(red: 0.85, green: 0.18, blue: 0.18)
    }
    if let num = Int(name), num >= 9000 {
        return Color(red: 0.85, green: 0.18, blue: 0.18)
    }
    // 순환(노랑): 0X번대
    if let num = Int(name), num < 10 {
        return Color(red: 0.90, green: 0.75, blue: 0.10)
    }
    // 간선(파랑): 3자리
    if let num = Int(name), num >= 100 && num <= 399 {
        return Color(red: 0.16, green: 0.38, blue: 0.73)
    }
    // 지선(초록): 4자리 or 기타
    return Color(red: 0.20, green: 0.60, blue: 0.27)
}

// MARK: - 위치 관리자

private class RouteLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    /// 서울 범위 내인지 확인 (대략적 바운딩 박스)
    static func isInSeoul(_ coord: CLLocationCoordinate2D) -> Bool {
        return coord.latitude >= 37.41 && coord.latitude <= 37.70
            && coord.longitude >= 126.76 && coord.longitude <= 127.18
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self.userLocation = locations.last?.coordinate
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // location error
    }
}

// MARK: - SearchRouteView

struct SearchRouteView: View {

    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var navigationVM: NavigationVM
    @EnvironmentObject private var scheduleVM: ScheduleVM

    @StateObject private var locationManager = RouteLocationManager()

    // 경로 지점 (배열 — 다중경유 확장 대비. first=출발, last=도착, 중간=경유지)
    private static let seoulStation = RoutePoint(name: "서울역", lat: 37.5547, lon: 126.9707)
    @State private var routePoints: [RoutePoint] = [
        seoulStation,
        RoutePoint(name: "", lat: 0, lon: 0)
    ]

    private var startPoint: RoutePoint {
        get { routePoints[0] }
        nonmutating set { routePoints[0] = newValue }
    }
    private var endPoint: RoutePoint {
        get { routePoints[routePoints.count - 1] }
        nonmutating set { routePoints[routePoints.count - 1] = newValue }
    }

    // 검색 시트
    @State private var searchTarget: Int = 0 // routePoints 배열 인덱스
    @State private var showSearchSheet = false
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []

    // 지도 위치 선택
    @State private var mapPickerRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var isReverseGeocoding = false
    @State private var pickerAddress: String = ""
    @State private var geocodeToken: UUID = UUID()

    // 경로 (모드별 독립 저장)
    @State private var selectedMode: Int = 0
    @State private var selectedRoute: RouteResult? = nil
    @State private var routesByMode: [[RouteResult]] = [[], [], []]
    @State private var loadedModes: Set<Int> = []
    @State private var departureDate: Date = Date()
    @State private var showTimePicker: Bool = false

    private let modes = ["전체", "버스", "지하철"]

    private var departureTimeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        if Calendar.current.isDateInToday(departureDate) {
            formatter.dateFormat = "오늘 a h:mm"
        } else if Calendar.current.isDateInTomorrow(departureDate) {
            formatter.dateFormat = "내일 a h:mm"
        } else {
            formatter.dateFormat = "M/d (E) a h:mm"
        }
        return formatter.string(from: departureDate)
    }

    private func departureArrivalText(totalMinutes: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "H:mm"
        let dep = formatter.string(from: departureDate)
        let arrival = departureDate.addingTimeInterval(Double(totalMinutes) * 60)
        let arr = formatter.string(from: arrival)
        return "\(dep) - \(arr)"
    }

    private func routePointLabel(at index: Int) -> String {
        let point = routePoints[index]
        if point.name.isEmpty {
            if index == 0 { return "출발지 선택" }
            if index == routePoints.count - 1 { return "도착지 선택" }
            return "경유지 선택"
        }
        return point.name
    }

    // MARK: - 위치 초기 설정

    private func setupStartLocation() {
        if let userCoord = locationManager.userLocation {
            if RouteLocationManager.isInSeoul(userCoord) {
                startPoint = RoutePoint(name: "현재 위치", lat: userCoord.latitude, lon: userCoord.longitude)
            } else {
                startPoint = Self.seoulStation
            }
        } else {
            startPoint = Self.seoulStation
        }
    }

    // MARK: - 지도 피커 초기 위치 설정

    private func setupMapPickerRegion() {
        let point = routePoints[searchTarget]
        if point.lat != 0 {
            mapPickerRegion.center = CLLocationCoordinate2D(
                latitude: point.lat, longitude: point.lon
            )
        } else if searchTarget == 0, let coord = locationManager.userLocation {
            mapPickerRegion.center = coord
        }
        pickerAddress = ""
        geocodeMapCenter()
    }

    // MARK: - 장소 검색 (MKLocalSearch)

    private func searchPlace(_ query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )

        MKLocalSearch(request: request).start { response, _ in
            DispatchQueue.main.async {
                searchResults = response?.mapItems ?? []
            }
        }
    }

    /// 검색 결과 선택 → 지도 카메라 이동 (시트 닫지 않음)
    private func moveMapToSearchResult(_ item: MKMapItem) {
        let coord = item.placemark.coordinate
        mapPickerRegion.center = coord
        searchText = ""
        searchResults = []
    }

    /// 지도 중심 좌표 변경 시 디바운스 역지오코딩 (실시간 주소 표시)
    private func geocodeMapCenter() {
        let token = UUID()
        geocodeToken = token

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            guard geocodeToken == token else { return }
            let coord = mapPickerRegion.center
            let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
                DispatchQueue.main.async {
                    guard geocodeToken == token else { return }
                    let p = placemarks?.first
                    pickerAddress = p?.name ?? p?.thoroughfare ?? p?.locality ?? ""
                }
            }
        }
    }

    /// 현재 위치로 지도 카메라 이동
    private func moveMapToCurrentLocation() {
        if let coord = locationManager.userLocation {
            mapPickerRegion.center = coord
        }
    }

    // MARK: - API 호출

    private func fetchRoutes() {
        guard endPoint.lat != 0 && endPoint.lon != 0 else { return }

        for mode in 0..<3 {
            fetchRoutesForMode(mode)
        }
    }

    private func clearAllRoutes() {
        routesByMode = [[], [], []]
        loadedModes = []
    }

    private func fetchRoutesForMode(_ mode: Int) {
        guard endPoint.lat != 0 && endPoint.lon != 0 else { return }
        guard !loadedModes.contains(mode) else { return }

        let modeParam = String(mode == 1 ? 1 : (mode == 2 ? 2 : 0))

        let sLat = startPoint.lat
        let sLon = startPoint.lon
        let eLat = endPoint.lat
        let eLon = endPoint.lon

        // [SEC-09] 직접 cleartext http://ws.bus.go.kr 호출 → 핀된 HTTPS 프록시(api.nunulala.com) 경유
        Task {
            let queryItems = [
                URLQueryItem(name: "startX", value: String(sLon)),
                URLQueryItem(name: "startY", value: String(sLat)),
                URLQueryItem(name: "endX", value: String(eLon)),
                URLQueryItem(name: "endY", value: String(eLat)),
                URLQueryItem(name: "mode", value: modeParam)
            ]

            guard let data = try? await APIClient.shared.requestData(
                path: "/api/transit/bus/path",
                queryItems: queryItems,
                authRefresh: true
            ) else { return }

            guard let decoded = try? JSONDecoder().decode(SeoulRouteResponse.self, from: data),
                  decoded.msgHeader?.headerCd == "0" else { return }

            let items = decoded.msgBody?.itemList ?? []

            let results: [RouteResult] = items.compactMap { item -> RouteResult? in
                        guard !item.pathList.isEmpty else { return nil }
                        var segments: [RouteSegment] = []

                        // 도보: 출발지 → 첫 정류장
                        if let first = item.pathList.first,
                           let fy = Double(first.fy ?? ""),
                           let fx = Double(first.fx ?? "") {
                            if let walk = self.makeWalkingSegment(
                                fromLat: sLat, fromLon: sLon,
                                toLat: fy, toLon: fx,
                                fromName: "출발지", toName: first.fname ?? ""
                            ) { segments.append(walk) }
                        }

                        // 교통 세그먼트 + 환승 도보
                        for (i, path) in item.pathList.enumerated() {
                            let isSubway = path.railLinkList != nil
                            let name = path.routeNm ?? ""
                            segments.append(RouteSegment(
                                type: isSubway ? .subway : .bus,
                                name: name,
                                boardingName: path.fname ?? "",
                                alightingName: path.tname ?? "",
                                color: isSubway ? subwayColor(for: name) : busColor(for: name),
                                routeId: path.routeId ?? "",
                                boardingLat: Double(path.fy ?? "") ?? 0,
                                boardingLon: Double(path.fx ?? "") ?? 0,
                                alightingLat: Double(path.ty ?? "") ?? 0,
                                alightingLon: Double(path.tx ?? "") ?? 0
                            ))

                            // 도보: 현 하차 → 다음 승차 (환승)
                            if i < item.pathList.count - 1 {
                                let next = item.pathList[i + 1]
                                if let ty = Double(path.ty ?? ""),
                                   let tx = Double(path.tx ?? ""),
                                   let fy = Double(next.fy ?? ""),
                                   let fx = Double(next.fx ?? "") {
                                    if let walk = self.makeWalkingSegment(
                                        fromLat: ty, fromLon: tx,
                                        toLat: fy, toLon: fx,
                                        fromName: path.tname ?? "", toName: next.fname ?? ""
                                    ) { segments.append(walk) }
                                }
                            }
                        }

                        // 도보: 마지막 정류장 → 도착지
                        if let last = item.pathList.last,
                           let ty = Double(last.ty ?? ""),
                           let tx = Double(last.tx ?? "") {
                            if let walk = self.makeWalkingSegment(
                                fromLat: ty, fromLon: tx,
                                toLat: eLat, toLon: eLon,
                                fromName: last.tname ?? "", toName: "도착지"
                            ) { segments.append(walk) }
                        }

                        let transitCount = segments.filter { $0.type != .walking }.count
                        let totalDistance = item.distance ?? 0
                        let totalFare = self.applyFares(to: &segments, totalDistance: totalDistance)
                        return RouteResult(
                            totalTime: item.time ?? 0,
                            totalDistance: totalDistance,
                            transferCount: max(transitCount - 1, 0),
                            segments: segments,
                            totalFare: totalFare
                )
            }

            await MainActor.run {
                routesByMode[mode] = results
                loadedModes.insert(mode)
                self.enrichSegmentsWithTAGO(mode: mode)
            }
        }
    }

    // MARK: - TAGO 세그먼트 소요시간 보강

    private func enrichSegmentsWithTAGO(mode: Int) {
        Task {
            var routes = routesByMode[mode]
            for ri in routes.indices {
                var segments = routes[ri].segments
                let totalTime = routes[ri].totalTime
                var enriched = false

                for si in segments.indices {
                    switch segments[si].type {
                    case .subway:
                        if let minutes = await calcSubwayMinutes(segment: segments[si]) {
                            segments[si].estimatedMinutes = minutes
                            enriched = true
                        }
                    case .bus:
                        if let minutes = await calcBusMinutes(segment: segments[si]) {
                            segments[si].estimatedMinutes = minutes
                            enriched = true
                        }
                    case .walking:
                        break
                    }
                }

                // 폴백: TAGO에서 못 채운 세그먼트는 거리 비율로 분배
                let unfilledIndices = segments.indices.filter { segments[$0].type != .walking && segments[$0].estimatedMinutes == 0 }
                if !unfilledIndices.isEmpty {
                    let walkMinutes = segments.filter { $0.type == .walking }.reduce(0) { $0 + $1.estimatedMinutes }
                    let filledMinutes = segments.filter { $0.type != .walking && $0.estimatedMinutes > 0 }.reduce(0) { $0 + $1.estimatedMinutes }
                    let remaining = max(0, totalTime - walkMinutes - filledMinutes)
                    let totalUnfilledDist = unfilledIndices.reduce(0.0) { $0 + haversineDistance(
                        lat1: segments[$1].boardingLat, lon1: segments[$1].boardingLon,
                        lat2: segments[$1].alightingLat, lon2: segments[$1].alightingLon
                    ) }

                    for idx in unfilledIndices {
                        if totalUnfilledDist > 0 {
                            let dist = haversineDistance(
                                lat1: segments[idx].boardingLat, lon1: segments[idx].boardingLon,
                                lat2: segments[idx].alightingLat, lon2: segments[idx].alightingLon
                            )
                            segments[idx].estimatedMinutes = max(1, Int(Double(remaining) * dist / totalUnfilledDist))
                        } else {
                            segments[idx].estimatedMinutes = max(1, remaining / max(1, unfilledIndices.count))
                        }
                    }
                }

                routes[ri] = RouteResult(
                    totalTime: totalTime,
                    totalDistance: routes[ri].totalDistance,
                    transferCount: routes[ri].transferCount,
                    segments: segments,
                    totalFare: routes[ri].totalFare
                )
            }

            await MainActor.run {
                routesByMode[mode] = routes
            }
        }
    }

    // MARK: - 지하철 소요시간 계산

    private func calcSubwayMinutes(segment: RouteSegment) async -> Int? {
        // 1. 탑승역/하차역 ID 조회
        guard let boardingStation = await fetchSubwayStationId(stationName: segment.boardingName, routeName: segment.name),
              let alightingStation = await fetchSubwayStationId(stationName: segment.alightingName, routeName: segment.name) else {
            return nil
        }

        // 2. 요일 코드: 평일=01, 토=02, 일/공휴=03
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: departureDate)
        let dailyTypeCode: String
        switch weekday {
        case 1: dailyTypeCode = "03"
        case 7: dailyTypeCode = "02"
        default: dailyTypeCode = "01"
        }

        // 상/하행 판단: 탑승역 ID < 하차역 ID면 하행(2), 아니면 상행(1) (근사)
        let upDown = (boardingStation.id ?? "") < (alightingStation.id ?? "") ? "2" : "1"

        // 3. 양역 시간표 조회
        guard let boardingId = boardingStation.id,
              let alightingId = alightingStation.id else { return nil }

        let depSchedules = await fetchSubwaySchedule(stationId: boardingId, dailyTypeCode: dailyTypeCode, upDownTypeCode: upDown)
        let arrSchedules = await fetchSubwaySchedule(stationId: alightingId, dailyTypeCode: dailyTypeCode, upDownTypeCode: upDown)

        guard !depSchedules.isEmpty, !arrSchedules.isEmpty else { return nil }

        // 4. 현재 시간 이후 가장 가까운 출발 매칭
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmmss"
        let nowStr = formatter.string(from: departureDate)

        // 같은 열차 매칭: endSubwayStationId + subwayRouteId 일치
        for dep in depSchedules {
            guard let depTime = dep.depTime, depTime >= nowStr else { continue }
            guard let depRouteId = dep.subwayRouteId, let depEndId = dep.endSubwayStationId else { continue }

            for arr in arrSchedules {
                guard let arrTime = arr.arrTime,
                      arr.subwayRouteId == depRouteId,
                      arr.endSubwayStationId == depEndId,
                      arrTime > depTime else { continue }

                // 소요시간 계산
                let depMinutes = timeStringToMinutes(depTime)
                let arrMinutes = timeStringToMinutes(arrTime)
                let diff = arrMinutes - depMinutes
                if diff > 0 && diff < 180 { return diff }
            }
        }

        return nil
    }

    private func timeStringToMinutes(_ hhmmss: String) -> Int {
        guard hhmmss.count >= 4 else { return 0 }
        let h = Int(hhmmss.prefix(2)) ?? 0
        let m = Int(hhmmss.dropFirst(2).prefix(2)) ?? 0
        return h * 60 + m
    }

    private func fetchSubwayStationId(stationName: String, routeName: String) async -> (id: String?, name: String?)? {
        // [SEC-09] cleartext http://apis.data.go.kr 직접호출 → 핀된 HTTPS 프록시 경유
        do {
            let data = try await APIClient.shared.requestData(
                path: "/api/transit/subway/station",
                queryItems: [URLQueryItem(name: "subwayStationName", value: stationName)],
                authRefresh: true
            )
            let decoded = try JSONDecoder().decode(TAGOResponse<TAGOSubwayStation>.self, from: data)
            let items = decoded.response?.body?.items?.item ?? []

            // 노선명 매칭 (ex: "3호선")
            let matched = items.first { station in
                station.subwayRouteName?.contains(routeName.replacingOccurrences(of: "호선", with: "")) == true
            } ?? items.first

            return (id: matched?.subwayStationId, name: matched?.subwayStationName)
        } catch {
            return nil
        }
    }

    private func fetchSubwaySchedule(stationId: String, dailyTypeCode: String, upDownTypeCode: String) async -> [TAGOSubwaySchedule] {
        // [SEC-09] cleartext http://apis.data.go.kr 직접호출 → 핀된 HTTPS 프록시 경유
        do {
            let data = try await APIClient.shared.requestData(
                path: "/api/transit/subway/schedule",
                queryItems: [
                    URLQueryItem(name: "subwayStationId", value: stationId),
                    URLQueryItem(name: "dailyTypeCode", value: dailyTypeCode),
                    URLQueryItem(name: "upDownTypeCode", value: upDownTypeCode)
                ],
                authRefresh: true
            )
            let decoded = try JSONDecoder().decode(TAGOResponse<TAGOSubwaySchedule>.self, from: data)
            return decoded.response?.body?.items?.item ?? []
        } catch {
            return []
        }
    }

    // MARK: - 버스 소요시간 계산 (서울)

    private func calcBusMinutes(segment: RouteSegment) async -> Int? {
        // routeId가 없으면 계산 불가 — SeoulPathSegment에서 가져와야 하는데
        // 현재 RouteSegment에 routeId가 없으므로 이름 기반으로 도착정보 조회
        // 서울 버스: getArrInfoByRouteAll은 routeId(숫자)가 필요
        // routeId는 SeoulPathSegment.routeId에 있었지만 RouteSegment로 전달되지 않음
        // → RouteSegment에 routeId 추가 필요

        guard !segment.routeId.isEmpty else { return nil }

        // [SEC-09] cleartext http://ws.bus.go.kr 직접호출 → 핀된 HTTPS 프록시 경유
        do {
            let data = try await APIClient.shared.requestData(
                path: "/api/transit/bus/arrival",
                queryItems: [URLQueryItem(name: "busRouteId", value: segment.routeId)],
                authRefresh: true
            )
            let decoded = try JSONDecoder().decode(SeoulBusArrivalResponse.self, from: data)
            guard decoded.msgHeader?.headerCd == "0" else { return nil }
            let items = decoded.msgBody?.itemList ?? []

            // 탑승/하차 정류소 매칭
            let boardingItem = items.first { $0.stNm == segment.boardingName }
            let alightingItem = items.first { $0.stNm == segment.alightingName }

            guard let bOrd = boardingItem?.staOrd.flatMap({ Int($0) }),
                  let aOrd = alightingItem?.staOrd.flatMap({ Int($0) }),
                  let bExps = boardingItem?.exps1.flatMap({ Int($0) }),
                  let aExps = alightingItem?.exps1.flatMap({ Int($0) }) else { return nil }

            // 같은 방향 검증: 하차 순번이 탑승보다 뒤
            guard aOrd > bOrd else { return nil }

            let diffSeconds = aExps - bExps
            guard diffSeconds > 0 else { return nil }

            return max(1, diffSeconds / 60)
        } catch {
            return nil
        }
    }

    // MARK: - 지도에서 위치 선택 (역지오코딩)

    private func reverseGeocodeAndSelect() {
        isReverseGeocoding = true
        let coord = mapPickerRegion.center
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                isReverseGeocoding = false
                let placemark = placemarks?.first
                let name = placemark?.name
                    ?? placemark?.thoroughfare
                    ?? placemark?.locality
                    ?? String(format: "%.4f, %.4f", coord.latitude, coord.longitude)
                let point = RoutePoint(name: name, lat: coord.latitude, lon: coord.longitude)

                routePoints[searchTarget] = point
                showSearchSheet = false
                searchText = ""
                searchResults = []
                clearAllRoutes()
            }
        }
    }

    // MARK: - 출발/도착 교환

    private func swapPoints() {
        routePoints.reverse()
        clearAllRoutes()
        fetchRoutes()
    }

    // MARK: - Body

    var body: some View {
        if let planModel = scheduleVM.currentPlanModel {
            VStack(spacing: 0) {
                routeHeader()
                modeTabBar()

                TabView(selection: $selectedMode) {
                    ForEach(0..<3, id: \.self) { mode in
                        routeTabContent(mode: mode)
                            .tag(mode)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(Color.getColour(.background_yellow_white))
            .onAppear {
                if endPoint.lat == 0 {
                    endPoint = RoutePoint(
                        name: planModel.placeModel.title,
                        lat: planModel.placeModel.address.lat,
                        lon: planModel.placeModel.address.lon
                    )
                }
                locationManager.requestLocation()
            }
            .onReceive(locationManager.$userLocation) { location in
                guard let _ = location, startPoint.name == Self.seoulStation.name || startPoint.name == "현재 위치" else { return }
                setupStartLocation()
            }
            .sheet(isPresented: $showSearchSheet) {
                locationSearchSheet()
            }
            .sheet(item: $selectedRoute) { route in
                RouteDetailSheet(
                    route: route,
                    startPoint: startPoint,
                    endPoint: endPoint,
                    locationManager: locationManager,
                    departureDate: departureDate
                )
            }
        }
    }

    // MARK: - 탭별 경로 콘텐츠

    @ViewBuilder
    private func routeTabContent(mode: Int) -> some View {
        let routes = routesByMode[mode]
        if routes.isEmpty && !loadedModes.contains(mode) {
            VStack {
                Spacer()
                Text("경로를 검색해주세요")
                    .font(.system(size: 15))
                    .foregroundColor(Color.getColour(.label_alternative))
                Spacer()
            }
        } else if routes.isEmpty {
            VStack {
                Spacer()
                Text("경로를 찾을 수 없습니다")
                    .font(.system(size: 15))
                    .foregroundColor(Color.getColour(.label_alternative))
                Spacer()
            }
        } else {
            ScrollView(.vertical) {
                routeCardList(routes: routes)
            }
        }
    }

    // MARK: - Route Header (탭하여 검색)

    @ViewBuilder
    private func routeHeader() -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                ImageButton(imageUrl: "icon_back", imageSize: 30) {
                    presentationMode.wrappedValue.dismiss()
                    navigationVM.goBack()
                }

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(routePoints.indices, id: \.self) { index in
                        if index > 0 {
                            Rectangle()
                                .fill(Color.getColour(.label_alternative))
                                .frame(width: 1.5, height: 12)
                                .padding(.leading, 5)
                        }
                        Button(action: {
                            searchTarget = index
                            setupMapPickerRegion()
                            showSearchSheet = true
                        }) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(index == 0
                                          ? Color.getColour(.label_alternative)
                                          : Color.getColour(.label_strong))
                                    .frame(width: 12, height: 12)
                                Text(routePointLabel(at: index))
                                    .font(.system(size: 17, weight: index == routePoints.count - 1 ? .semibold : .regular))
                                    .foregroundColor(index == 0
                                                     ? Color.getColour(.label_normal)
                                                     : Color.getColour(.label_strong))
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.leading, 4)

                Spacer()

                Button(action: { swapPoints() }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 18))
                        .foregroundColor(Color.getColour(.label_alternative))
                        .padding(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 12, trailing: 16))

            // 출발시각
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
                Button(action: { showTimePicker.toggle() }) {
                    Text(departureTimeText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.getColour(.label_normal))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.getColour(.fill_normal))
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                if !Calendar.current.isDate(departureDate, equalTo: Date(), toGranularity: .minute) {
                    Button(action: { departureDate = Date() }) {
                        Text("지금")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.getColour(.label_alternative))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))

            if showTimePicker {
                DatePicker("", selection: $departureDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }

            // 길찾기 버튼
            Button(action: {
                clearAllRoutes()
                fetchRoutes()
            }) {
                Text("길찾기")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        (endPoint.lat != 0 && endPoint.lon != 0)
                            ? Color.getColour(.label_strong)
                            : Color.getColour(.label_alternative)
                    )
                    .cornerRadius(8)
            }
            .disabled(endPoint.lat == 0 || endPoint.lon == 0)
            .buttonStyle(PlainButtonStyle())
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16))
        }
        .background(Color.getColour(.background_white))
    }

    // MARK: - 장소 검색 시트

    @ViewBuilder
    private func locationSearchSheet() -> some View {
        VStack(spacing: 0) {
            // 검색바
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.getColour(.label_alternative))
                TextField(
                    searchTarget == 0 ? "출발지 검색" : "도착지 검색",
                    text: $searchText,
                    onCommit: { searchPlace(searchText) }
                )
                .font(.system(size: 16))
                .disableAutocorrection(true)

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.getColour(.label_alternative))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(12)
            .background(Color.getColour(.background_alternative))
            .cornerRadius(10)
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
            .onChange(of: searchText) { newValue in
                searchPlace(newValue)
            }

            // 검색 결과 리스트 (검색어 입력 시 지도 위에 표시)
            if !searchResults.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(searchResults, id: \.self) { item in
                            Button(action: { moveMapToSearchResult(item) }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "mappin.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.getColour(.label_alternative))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.name ?? "")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color.getColour(.label_strong))
                                        if let address = item.placemark.title {
                                            Text(address)
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.getColour(.label_alternative))
                                                .lineLimit(1)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Divider().padding(.leading, 44)
                        }
                    }
                }
                .frame(maxHeight: 180)
            }

            // 지도 피커 (항상 표시)
            mapLocationPicker()
        }
        .onAppear {
            setupMapPickerRegion()
        }
    }

    // MARK: - 지도 위치 선택 피커

    @ViewBuilder
    private func mapLocationPicker() -> some View {
        ZStack {
            Map(coordinateRegion: $mapPickerRegion, showsUserLocation: true)

            // 고정 핀 (커스텀 어노테이션 핀)
            Image("icon_map_pin")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color.getColour(.label_strong))
                .frame(width: 26, height: 32)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
                .offset(y: -16)

            // 현재 위치 버튼 (좌상단)
            VStack {
                HStack {
                    Button(action: { moveMapToCurrentLocation() }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.getColour(.label_strong))
                            .padding(10)
                            .background(Color.getColour(.background_white))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .padding(12)
                Spacer()
            }

            // 주소 + 좌표 라벨 + 선택 버튼 (하단 중앙)
            VStack {
                Spacer()

                VStack(spacing: 4) {
                    if !pickerAddress.isEmpty {
                        Text(pickerAddress)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.getColour(.label_strong))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.getColour(.background_white).opacity(0.92))
                            .cornerRadius(6)
                    }

                    Text(String(format: "%.5f, %.5f",
                                mapPickerRegion.center.latitude,
                                mapPickerRegion.center.longitude))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color.getColour(.label_alternative))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.getColour(.background_white).opacity(0.9))
                        .cornerRadius(4)

                    Button(action: { reverseGeocodeAndSelect() }) {
                        Text(isReverseGeocoding ? "위치 확인 중..." : "이 위치 선택")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.getColour(.background_white))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                isReverseGeocoding
                                ? Color.getColour(.label_alternative)
                                : Color.getColour(.label_strong)
                            )
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isReverseGeocoding)
                }
                .padding(.bottom, 14)
            }
        }
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 16)
        .onChange(of: "\(Int(mapPickerRegion.center.latitude * 1000)),\(Int(mapPickerRegion.center.longitude * 1000))") { _ in
            geocodeMapCenter()
        }
        .onAppear {
            geocodeMapCenter()
        }
    }

    // MARK: - Mode Tab Bar

    @ViewBuilder
    private func modeTabBar() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<modes.count, id: \.self) { index in
                    Button(action: {
                        withAnimation { selectedMode = index }
                    }) {
                        VStack(spacing: 6) {
                            Text(modes[index])
                                .font(.system(size: 15, weight: selectedMode == index ? .bold : .regular))
                                .foregroundColor(
                                    selectedMode == index
                                    ? Color.getColour(.label_strong)
                                    : Color.getColour(.label_alternative)
                                )
                            Rectangle()
                                .fill(selectedMode == index ? Color.getColour(.label_strong) : Color.clear)
                                .frame(height: 2)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 10)

            Divider()
        }
        .background(Color.getColour(.background_white))
    }

    // MARK: - Route Card List

    @ViewBuilder
    private func routeCardList(routes: [RouteResult]) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(routes) { route in
                routeCard(route: route)
            }
        }
        .padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
    }

    // MARK: - Route Card

    @ViewBuilder
    private func routeCard(route: RouteResult) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                if route.totalTime > 0 {
                    Text("\(route.totalTime)분")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.getColour(.label_strong))
                } else {
                    Text(distanceText(route.totalDistance))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.getColour(.label_strong))
                }

                Text(departureArrivalText(totalMinutes: route.totalTime))
                    .font(.system(size: 13))
                    .foregroundColor(Color.getColour(.label_alternative))

                Spacer()

                HStack(spacing: 8) {
                    if route.transferCount > 0 {
                        Text("환승 \(route.transferCount)회")
                            .font(.system(size: 13))
                            .foregroundColor(Color.getColour(.label_alternative))
                    }
                    Text(distanceText(route.totalDistance))
                        .font(.system(size: 13))
                        .foregroundColor(Color.getColour(.label_alternative))
                    if route.totalFare > 0 {
                        Text("약 \(route.totalFare)원")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.getColour(.label_normal))
                    }
                }
            }
            .padding(.bottom, 12)

            segmentBarWithIcons(segments: route.segments)
        }
        .padding(16)
        .background(Color.getColour(.background_white))
        .cornerRadius(12)
        .onTapGesture {
            selectedRoute = route
        }
    }

    private func segmentWidths(segments: [RouteSegment], totalWidth: CGFloat) -> [CGFloat] {
        let minWidth: CGFloat = 52  // 모든 세그먼트 최소 너비
        let count = CGFloat(segments.count)

        // 1단계: 전체를 최소 너비로 채운 뒤 남은 너비를 비율로 분배
        let reservedWidth = minWidth * count
        let extraWidth = max(totalWidth - reservedWidth, 0)
        let totalMinutes = CGFloat(segments.reduce(0) { $0 + max($1.estimatedMinutes, 1) })

        let widths = segments.map { seg -> CGFloat in
            let ratio = CGFloat(max(seg.estimatedMinutes, 1)) / totalMinutes
            return minWidth + extraWidth * ratio
        }

        return widths
    }

    // MARK: - Segment Bar

    @ViewBuilder
    private func segmentBarWithIcons(segments: [RouteSegment]) -> some View {
        let barHeight: CGFloat = 36
        let labelHeight: CGFloat = 16
        let spacing: CGFloat = 1

        GeometryReader { geo in
            let totalSpacing = spacing * CGFloat(segments.count - 1)
            let totalWidth = geo.size.width - totalSpacing
            let widths = segmentWidths(segments: segments, totalWidth: totalWidth)

            VStack(spacing: 0) {
                // 바 영역
                HStack(spacing: spacing) {
                    ForEach(Array(segments.enumerated()), id: \.element.id) { index, seg in
                        let segColor = seg.type == .walking ? Color.getColour(.label_alternative) : seg.color

                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(segColor)

                            HStack(alignment: .center) {
                                Image(systemName: seg.type == .walking ? "figure.walk" : (seg.type == .subway ? "tram.fill" : "bus.fill"))
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)

                                Spacer()

                                if seg.estimatedMinutes > 0 {
                                    Text("\(seg.estimatedMinutes)분")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                        .lineLimit(1)
                                }
                            }
                            .padding(.horizontal, 6)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(width: widths[index], height: barHeight)
                    }
                }

                // 하단 레이블 영역
                HStack(spacing: spacing) {
                    ForEach(Array(segments.enumerated()), id: \.element.id) { index, seg in
                        let segColor = seg.type == .walking ? Color.getColour(.label_alternative) : seg.color
                        let label: String? = seg.type == .subway ? seg.boardingName : (seg.type == .bus ? seg.name : nil)

                        Group {
                            if let label {
                                Text(label)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(segColor)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Color.clear
                            }
                        }
                        .frame(width: widths[index], height: labelHeight)
                    }
                }
            }
        }
        .frame(height: barHeight + labelHeight)
    }

    // MARK: - Route Detail Section

    @ViewBuilder
    private func routeDetailSection(segments: [RouteSegment]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .padding(.bottom, 12)

            ForEach(Array(segments.enumerated()), id: \.element.id) { index, seg in
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(seg.type == .walking ? Color.getColour(.label_alternative) : seg.color)
                                .frame(width: 24, height: 24)
                            Image(systemName: seg.type == .walking ? "figure.walk" : (seg.type == .subway ? "tram.fill" : "bus.fill"))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        if index < segments.count - 1 {
                            Rectangle()
                                .fill((seg.type == .walking ? Color.getColour(.label_alternative) : seg.color).opacity(0.3))
                                .frame(width: 3, height: 40)
                        }
                    }
                    .frame(width: 24)

                    if seg.type == .walking {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("도보 약 \(seg.estimatedMinutes)분")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.getColour(.label_strong))
                            Text("\(seg.boardingName) → \(seg.alightingName) (\(distanceText(seg.distanceMeters)))")
                                .font(.system(size: 16))
                                .foregroundColor(Color.getColour(.label_normal))
                                .padding(EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0))
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(seg.estimatedMinutes > 0 ? "\(seg.name) 약 \(seg.estimatedMinutes)분" : "\(seg.name)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.getColour(.label_strong))
                            Text("\(seg.boardingName) → \(seg.alightingName)")
                                .font(.system(size: 16))
                                .foregroundColor(Color.getColour(.label_normal))
                                .padding(EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0))
                        }
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: - Haversine 직선거리 계산

    private func haversineDistance(
        lat1: Double, lon1: Double,
        lat2: Double, lon2: Double
    ) -> Double {
        let R = 6371000.0
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2)
            + cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180)
            * sin(dLon / 2) * sin(dLon / 2)
        return R * 2 * atan2(sqrt(a), sqrt(1 - a))
    }

    private func makeWalkingSegment(
        fromLat: Double, fromLon: Double,
        toLat: Double, toLon: Double,
        fromName: String, toName: String
    ) -> RouteSegment? {
        let straight = haversineDistance(lat1: fromLat, lon1: fromLon, lat2: toLat, lon2: toLon)
        let walkDist = Int(straight * 1.3)
        guard walkDist > 30 else { return nil }
        return RouteSegment(
            type: .walking, name: "도보",
            boardingName: fromName, alightingName: toName,
            color: Color.getColour(.label_alternative),
            boardingLat: fromLat, boardingLon: fromLon,
            alightingLat: toLat, alightingLon: toLon,
            distanceMeters: walkDist,
            estimatedMinutes: max(1, walkDist / 67)
        )
    }

    // MARK: - 예상 요금 계산 (수도권 통합요금제 기준)

    /// 버스 기본요금 판별
    /// - M버스(광역급행): 3,000원
    /// - 광역버스(routeId 앞자리 11): 2,300원
    /// - 좌석/일반: 1,500원
    private func busBaseFare(_ seg: RouteSegment) -> Int {
        let name = seg.name
        let id = seg.routeId
        if name.hasPrefix("M") || name.hasPrefix("m") { return 3000 }
        if id.hasPrefix("11") { return 2300 }
        return 1500
    }

    /// 신분당선 추가요금
    private func subwayExtraFare(_ seg: RouteSegment) -> Int {
        seg.name.contains("신분당") ? 1000 : 0
    }

    /// 거리 추가요금 (수도권 통합요금제)
    /// 10km 초과 ~ 50km: 5km마다 +100원
    /// 50km 초과       : 8km마다 +100원
    private func distanceExtraFare(totalMeters: Int) -> Int {
        let km = Double(totalMeters) / 1000.0
        var extra = 0
        if km > 10 {
            let over10 = min(km - 10, 40)
            extra += Int(over10 / 5) * 100
        }
        if km > 50 {
            let over50 = km - 50
            extra += Int(over50 / 8) * 100
        }
        return extra
    }

    /// 전체 요금 계산 후 세그먼트에 fareLabel/fare 배분
    /// 수도권 통합환승: 첫 탑승에서 총 요금 부과, 이후 환승 세그먼트는 무료
    private func applyFares(to segments: inout [RouteSegment], totalDistance: Int) -> Int {
        let transitSegs = segments.filter { $0.type != .walking }
        guard !transitSegs.isEmpty else { return 0 }

        // 가장 비싼 세그먼트 기준으로 기본요금 결정
        let baseFare = transitSegs.map { seg -> Int in
            seg.type == .subway
                ? 1500 + subwayExtraFare(seg)
                : busBaseFare(seg)
        }.max() ?? 1500

        let totalFare = baseFare + distanceExtraFare(totalMeters: totalDistance)

        // 세그먼트별 요금 배분
        var firstTransit = true
        for i in segments.indices {
            switch segments[i].type {
            case .walking:
                segments[i].fare = 0
                segments[i].fareLabel = "-"
            case .subway, .bus:
                if firstTransit {
                    segments[i].fare = totalFare
                    segments[i].fareLabel = fareBreakdown(base: baseFare, extra: distanceExtraFare(totalMeters: totalDistance))
                    firstTransit = false
                } else {
                    segments[i].fare = 0
                    segments[i].fareLabel = "무료환승"
                }
            }
        }
        return totalFare
    }

    private func fareBreakdown(base: Int, extra: Int) -> String {
        extra > 0 ? "기본 \(base)원 + 거리 \(extra)원" : "기본 \(base)원"
    }

    // MARK: - Helpers

    private func distanceText(_ meters: Int) -> String {
        if meters >= 1000 {
            let km = Double(meters) / 1000.0
            return String(format: "%.1fkm", km)
        }
        return "\(meters)m"
    }
}

// MARK: - Route Map View (MKMapView + MKDirections + Polyline)

private struct RouteMapView: UIViewRepresentable {
    let segments: [RouteSegment]
    let startPoint: RoutePoint
    let endPoint: RoutePoint
    var centerOnUserTrigger: Bool = false

    func makeCoordinator() -> RouteMapCoordinator {
        RouteMapCoordinator()
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true

        fitRegion(mapView)
        addStationAnnotations(mapView)
        requestDirections(mapView: mapView, coordinator: context.coordinator)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        guard centerOnUserTrigger != context.coordinator.lastCenterOnUserTrigger else { return }
        context.coordinator.lastCenterOnUserTrigger = centerOnUserTrigger
        if let userCoord = mapView.userLocation.location?.coordinate {
            let region = MKCoordinateRegion(center: userCoord, latitudinalMeters: 600, longitudinalMeters: 600)
            mapView.setRegion(region, animated: true)
        }
    }

    // MARK: - 초기 영역 설정

    private func fitRegion(_ mapView: MKMapView) {
        var coords: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: startPoint.lat, longitude: startPoint.lon),
            CLLocationCoordinate2D(latitude: endPoint.lat, longitude: endPoint.lon)
        ]
        for seg in segments where seg.boardingLat != 0 {
            coords.append(CLLocationCoordinate2D(latitude: seg.boardingLat, longitude: seg.boardingLon))
            coords.append(CLLocationCoordinate2D(latitude: seg.alightingLat, longitude: seg.alightingLon))
        }
        guard !coords.isEmpty else { return }

        var minLat = coords[0].latitude, maxLat = coords[0].latitude
        var minLon = coords[0].longitude, maxLon = coords[0].longitude
        for c in coords {
            minLat = min(minLat, c.latitude); maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude); maxLon = max(maxLon, c.longitude)
        }
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.4 + 0.005,
            longitudeDelta: (maxLon - minLon) * 1.4 + 0.005
        )
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)
    }

    // MARK: - 정류장 어노테이션

    private func addStationAnnotations(_ mapView: MKMapView) {
        let start = RouteStationAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: startPoint.lat, longitude: startPoint.lon),
            title: startPoint.name, isStart: true
        )
        let end = RouteStationAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: endPoint.lat, longitude: endPoint.lon),
            title: endPoint.name, isStart: false
        )
        mapView.addAnnotations([start, end])
    }

    // MARK: - MKDirections 요청

    private func requestDirections(mapView: MKMapView, coordinator: RouteMapCoordinator) {
        for seg in segments {
            guard seg.boardingLat != 0, seg.alightingLat != 0 else { continue }

            let source = CLLocationCoordinate2D(latitude: seg.boardingLat, longitude: seg.boardingLon)
            let dest = CLLocationCoordinate2D(latitude: seg.alightingLat, longitude: seg.alightingLon)

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: dest))
            request.transportType = seg.type == .walking ? .walking : .automobile

            let style = PolylineStyle(
                color: UIColor(seg.color),
                isDashed: seg.type == .walking,
                lineWidth: seg.type == .walking ? 3 : 5
            )

            let level: MKOverlayLevel = seg.type == .walking ? .aboveRoads : .aboveLabels
            MKDirections(request: request).calculate { response, error in
                DispatchQueue.main.async {
                    if let route = response?.routes.first {
                        coordinator.styles[route.polyline] = style
                        mapView.addOverlay(route.polyline, level: level)
                    } else {
                        // fallback: 직선
                        var coords = [source, dest]
                        let polyline = MKPolyline(coordinates: &coords, count: 2)
                        coordinator.styles[polyline] = style
                        mapView.addOverlay(polyline, level: level)
                    }
                }
            }
        }
    }
}

// MARK: - Polyline Style

private struct PolylineStyle {
    let color: UIColor
    let isDashed: Bool
    let lineWidth: CGFloat
}

// MARK: - Route Station Marker View (PlaceAnnotationMarkerView 동일 패턴)

private final class RouteStationMarkerView: MKAnnotationView {
    private let pinImageView = UIImageView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupViews() {
        backgroundColor = .clear

        let pinWidth: CGFloat = 26
        let pinHeight: CGFloat = 32
        let spacing: CGFloat = 2
        let titleHeight: CGFloat = 14
        let containerWidth: CGFloat = 80
        let totalHeight = pinHeight + spacing + titleHeight

        pinImageView.image = UIImage(named: "icon_map_pin")?.withRenderingMode(.alwaysTemplate)
        pinImageView.contentMode = .scaleAspectFit
        pinImageView.frame = CGRect(
            x: (containerWidth - pinWidth) / 2, y: 0,
            width: pinWidth, height: pinHeight
        )
        addSubview(pinImageView)

        let iconSize: CGFloat = 13
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.frame = CGRect(
            x: (containerWidth - iconSize) / 2,
            y: (pinWidth / 2) - (iconSize / 2),
            width: iconSize, height: iconSize
        )
        addSubview(iconImageView)

        titleLabel.font = .systemFont(ofSize: 10, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = UIColor(named: "label_strong") ?? .label
        titleLabel.backgroundColor = .white
        titleLabel.layer.cornerRadius = 3
        titleLabel.layer.masksToBounds = true
        titleLabel.frame = CGRect(
            x: 0, y: pinHeight + spacing,
            width: containerWidth, height: titleHeight
        )
        addSubview(titleLabel)

        frame = CGRect(x: 0, y: 0, width: containerWidth, height: totalHeight)
        centerOffset = CGPoint(x: 0, y: -(totalHeight / 2 - pinHeight))
    }

    func configure(with station: RouteStationAnnotation) {
        pinImageView.tintColor = UIColor(named: "label_strong") ?? .black
        let config = UIImage.SymbolConfiguration(pointSize: 11)
        iconImageView.image = UIImage(
            systemName: station.isStart ? "figure.walk" : "flag.fill",
            withConfiguration: config
        )?.withRenderingMode(.alwaysTemplate)
        titleLabel.text = station.title
        annotation = station
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = nil
    }
}

// MARK: - Route Station Annotation

private class RouteStationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let isStart: Bool

    init(coordinate: CLLocationCoordinate2D, title: String?, isStart: Bool) {
        self.coordinate = coordinate
        self.title = title
        self.isStart = isStart
    }
}

// MARK: - Chevron Polyline Renderer ( > > > > 방향 화살표)

private class ChevronPolylineRenderer: MKPolylineRenderer {

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)

        let count = polyline.pointCount
        guard count >= 2 else { return }

        var points = [CGPoint]()
        for i in 0..<count {
            points.append(self.point(for: polyline.points()[i]))
        }

        let spacing: CGFloat = 50.0 / zoomScale
        let size: CGFloat = 5.0 / zoomScale
        var accumulated: CGFloat = spacing

        context.setStrokeColor(UIColor.white.withAlphaComponent(0.85).cgColor)
        context.setLineWidth(max(1.5 / zoomScale, 0.5))
        context.setLineCap(.round)
        context.setLineJoin(.round)

        for i in 1..<points.count {
            let p0 = points[i - 1]
            let p1 = points[i]
            let dx = p1.x - p0.x
            let dy = p1.y - p0.y
            let segLen = sqrt(dx * dx + dy * dy)
            guard segLen > 0 else { continue }

            let angle = atan2(dy, dx)

            while accumulated <= segLen {
                let t = accumulated / segLen
                let cx = p0.x + dx * t
                let cy = p0.y + dy * t

                let spread: CGFloat = .pi / 4
                let x1 = cx - size * cos(angle - spread)
                let y1 = cy - size * sin(angle - spread)
                let x2 = cx - size * cos(angle + spread)
                let y2 = cy - size * sin(angle + spread)

                context.beginPath()
                context.move(to: CGPoint(x: x1, y: y1))
                context.addLine(to: CGPoint(x: cx, y: cy))
                context.addLine(to: CGPoint(x: x2, y: y2))
                context.strokePath()

                accumulated += spacing
            }
            accumulated -= segLen
        }
    }
}

// MARK: - Route Detail Bottom Sheet

private struct RouteDetailSheet: View {
    let route: RouteResult
    let startPoint: RoutePoint
    let endPoint: RoutePoint
    let locationManager: RouteLocationManager
    let departureDate: Date

    @State private var centerOnUserTrigger: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // 핸들
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.getColour(.label_disable))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 16)

            // 요약 헤더
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(route.totalTime)분")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.getColour(.label_strong))
                    Text(departureArrivalText(totalMinutes: route.totalTime))
                        .font(.system(size: 13))
                        .foregroundColor(Color.getColour(.label_alternative))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    if route.totalFare > 0 {
                        Text("예상 \(route.totalFare)원")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.getColour(.label_strong))
                    }
                    HStack(spacing: 6) {
                        if route.transferCount > 0 {
                            Text("환승 \(route.transferCount)회")
                                .font(.system(size: 12))
                                .foregroundColor(Color.getColour(.label_alternative))
                        }
                        Text(distanceText(route.totalDistance))
                            .font(.system(size: 12))
                            .foregroundColor(Color.getColour(.label_alternative))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            // 맵 + 현재위치 버튼
            ZStack(alignment: .bottomTrailing) {
                RouteMapView(
                    segments: route.segments,
                    startPoint: startPoint,
                    endPoint: endPoint,
                    centerOnUserTrigger: centerOnUserTrigger
                )
                .frame(height: 280)

                // 현재 위치 버튼
                Button(action: {
                    locationManager.requestLocation()
                    centerOnUserTrigger.toggle()
                }) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.getColour(.label_strong))
                        .frame(width: 40, height: 40)
                        .background(Color.getColour(.background_white))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(12)
            }

            // 상세 경로 스크롤
            ScrollView {
                routeDetailSection(segments: route.segments)
                    .padding(16)
            }
        }
        .background(Color.getColour(.background_white))
    }

    private func departureArrivalText(totalMinutes: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "H:mm"
        let dep = formatter.string(from: departureDate)
        let arrival = departureDate.addingTimeInterval(Double(totalMinutes) * 60)
        let arr = formatter.string(from: arrival)
        return "\(dep) - \(arr)"
    }

    private func distanceText(_ meters: Int) -> String {
        meters >= 1000 ? String(format: "%.1fkm", Double(meters) / 1000.0) : "\(meters)m"
    }

    @ViewBuilder
    private func routeDetailSection(segments: [RouteSegment]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(segments.enumerated()), id: \.element.id) { index, seg in
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(seg.type == .walking ? Color.getColour(.label_alternative) : seg.color)
                                .frame(width: 24, height: 24)
                            Image(systemName: seg.type == .walking ? "figure.walk" : (seg.type == .subway ? "tram.fill" : "bus.fill"))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        if index < segments.count - 1 {
                            Rectangle()
                                .fill((seg.type == .walking ? Color.getColour(.label_alternative) : seg.color).opacity(0.3))
                                .frame(width: 3, height: 40)
                        }
                    }
                    .frame(width: 24)

                    VStack(alignment: .leading, spacing: 3) {
                        if seg.type == .walking {
                            Text("도보 \(seg.estimatedMinutes)분")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color.getColour(.label_strong))
                            Text("\(seg.boardingName) → \(seg.alightingName)")
                                .font(.system(size: 13))
                                .foregroundColor(Color.getColour(.label_alternative))
                        } else {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(seg.estimatedMinutes > 0 ? "\(seg.name)  \(seg.estimatedMinutes)분" : seg.name)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color.getColour(.label_strong))
                                Spacer()
                                // 요금 배지
                                Text(seg.fare > 0 ? "\(seg.fare)원" : seg.fareLabel)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(seg.fare > 0 ? Color.getColour(.label_strong) : Color.getColour(.label_alternative))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(seg.fare > 0
                                        ? Color.getColour(.background_alternative)
                                        : Color.clear)
                                    .cornerRadius(4)
                            }
                            Text("\(seg.boardingName) → \(seg.alightingName)")
                                .font(.system(size: 13))
                                .foregroundColor(Color.getColour(.label_alternative))
                            // 요금 세부 내역 (기본요금 + 거리 추가요금 분리 표시)
                            if seg.fare > 0 && seg.fareLabel.contains("+") {
                                Text(seg.fareLabel)
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.getColour(.label_alternative))
                            }
                        }
                    }
                    .padding(.top, 3)
                    .padding(.bottom, index < segments.count - 1 ? 0 : 0)

                    Spacer()
                }
                .padding(.bottom, index < segments.count - 1 ? 0 : 0)
            }
        }
    }
}


// MARK: - Route Map Coordinator

private class RouteMapCoordinator: NSObject, MKMapViewDelegate {
    var styles: [MKPolyline: PolylineStyle] = [:]
    var lastCenterOnUserTrigger: Bool = false

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline,
              let style = styles[polyline] else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = ChevronPolylineRenderer(polyline: polyline)
        renderer.strokeColor = style.color
        renderer.lineWidth = style.lineWidth
        if style.isDashed {
            renderer.lineDashPattern = [6, 4]
        }
        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let station = annotation as? RouteStationAnnotation else { return nil }
        let id = "routeStation"
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? RouteStationMarkerView
            ?? RouteStationMarkerView(annotation: station, reuseIdentifier: id)
        view.configure(with: station)
        return view
    }
}
