//
//  NativeMapView.swift
//  HiRoute
//
//  Created by Claude on 3/13/26.
//

import SwiftUI
import MapKit

// MARK: - NativeMapView (UIViewRepresentable)

struct NativeMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let showsUserLocation: Bool
    let annotations: [PlaceModel]
    let hotPlaces: [HotPlaceModel]
    let geoObjects: [GeoObjectModel]
    let selectedHotPlaceIds: Set<String>
    let onAnnotationTap: (PlaceModel) -> Void

    func makeCoordinator() -> MapDelegateCoordinator {
        MapDelegateCoordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = showsUserLocation
        mapView.setRegion(region, animated: false)

        // 어노테이션 뷰 등록 (dequeue 재사용)
        mapView.register(
            PlaceAnnotationMarkerView.self,
            forAnnotationViewWithReuseIdentifier: PlaceAnnotationMarkerView.reuseID
        )
        mapView.register(
            PlaceClusterMarkerView.self,
            forAnnotationViewWithReuseIdentifier: PlaceClusterMarkerView.reuseID
        )
        mapView.register(
            HotPlaceLabelMarkerView.self,
            forAnnotationViewWithReuseIdentifier: HotPlaceLabelMarkerView.reuseID
        )
        mapView.register(
            GeoObject3DMarkerView.self,
            forAnnotationViewWithReuseIdentifier: GeoObject3DMarkerView.reuseID
        )

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self

        // Region 동기화 — 유저 인터랙션 중에는 setRegion 차단 (스냅백 방지)
        if !context.coordinator.isUserInteracting,
           !mapView.region.isApproximatelyEqual(to: region) {
            mapView.setRegion(region, animated: true)
        }

        // 어노테이션 diff 업데이트
        updatePlaceAnnotations(on: mapView)
        updateHotPlaceLabels(on: mapView)
        updateGeoObjectAnnotations(on: mapView)

        // 오버레이 diff 업데이트
        updateHotPlaceOverlays(on: mapView, context: context)
    }

    // MARK: - Place Annotation Diff

    private func updatePlaceAnnotations(on mapView: MKMapView) {
        let existing = mapView.annotations.compactMap { $0 as? PlaceAnnotation }
        let existingIds = Set(existing.map { $0.placeModel.uid })
        let newIds = Set(annotations.map { $0.uid })

        let toRemove = existing.filter { !newIds.contains($0.placeModel.uid) }
        if !toRemove.isEmpty { mapView.removeAnnotations(toRemove) }

        let toAdd = annotations
            .filter { !existingIds.contains($0.uid) }
            .map { PlaceAnnotation(placeModel: $0) }
        if !toAdd.isEmpty { mapView.addAnnotations(toAdd) }
    }

    // MARK: - HotPlace Label Annotation Diff

    private func updateHotPlaceLabels(on mapView: MKMapView) {
        let visibleHotPlaces = hotPlaces.filter { selectedHotPlaceIds.contains($0.id) }

        let existing = mapView.annotations.compactMap { $0 as? HotPlaceLabelAnnotation }
        let existingIds = Set(existing.map { $0.hotPlace.id })
        let newIds = Set(visibleHotPlaces.map { $0.id })

        let toRemove = existing.filter { !newIds.contains($0.hotPlace.id) }
        if !toRemove.isEmpty { mapView.removeAnnotations(toRemove) }

        let toAdd = visibleHotPlaces
            .filter { !existingIds.contains($0.id) }
            .map { HotPlaceLabelAnnotation(hotPlace: $0) }
        if !toAdd.isEmpty { mapView.addAnnotations(toAdd) }
    }

    // MARK: - GeoObject Annotation Diff

    private func updateGeoObjectAnnotations(on mapView: MKMapView) {
        let existing = mapView.annotations.compactMap { $0 as? GeoObjectAnnotation }
        let existingIds = Set(existing.map { $0.geoObject.id })
        let newIds = Set(geoObjects.map { $0.id })

        let toRemove = existing.filter { !newIds.contains($0.geoObject.id) }
        if !toRemove.isEmpty { mapView.removeAnnotations(toRemove) }

        let toAdd = geoObjects
            .filter { !existingIds.contains($0.id) }
            .map { GeoObjectAnnotation(geoObject: $0) }
        if !toAdd.isEmpty { mapView.addAnnotations(toAdd) }
    }

    // MARK: - HotPlace Overlay (MKPolygon) Diff

    private func updateHotPlaceOverlays(on mapView: MKMapView, context: Context) {
        let visibleHotPlaces = hotPlaces.filter { selectedHotPlaceIds.contains($0.id) }

        let existingPolygons = mapView.overlays.compactMap { $0 as? MKPolygon }
        let existingIds = Set(existingPolygons.compactMap { $0.title })
        let newIds = Set(visibleHotPlaces.map { $0.id })

        // 제거
        let toRemove = existingPolygons.filter { !newIds.contains($0.title ?? "") }
        if !toRemove.isEmpty { mapView.removeOverlays(toRemove) }

        // 추가
        let idsToAdd = newIds.subtracting(existingIds)
        for hotPlace in visibleHotPlaces where idsToAdd.contains(hotPlace.id) {
            var coords = hotPlace.coordinates
            let polygon = MKPolygon(coordinates: &coords, count: coords.count)
            polygon.title = hotPlace.id
            context.coordinator.overlayColors[hotPlace.id] = (
                fill: UIColor(hotPlace.color).withAlphaComponent(0.3),
                stroke: UIColor(hotPlace.color)
            )
            mapView.addOverlay(polygon)
        }
    }
}

// MARK: - MKMapViewDelegate Coordinator

final class MapDelegateCoordinator: NSObject, MKMapViewDelegate {
    var parent: NativeMapView
    var overlayColors: [String: (fill: UIColor, stroke: UIColor)] = [:]

    /// 유저가 맵을 드래그/줌 중인지 (setRegion 차단용)
    var isUserInteracting = false

    init(parent: NativeMapView) {
        self.parent = parent
    }

    // MARK: Region 변경 감지

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        isUserInteracting = true
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        isUserInteracting = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !mapView.region.isApproximatelyEqual(to: self.parent.region) {
                self.parent.region = mapView.region
            }
        }
    }

    // MARK: Annotation View Factory (dequeue 재사용)

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        if let cluster = annotation as? MKClusterAnnotation {
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: PlaceClusterMarkerView.reuseID,
                for: cluster
            ) as! PlaceClusterMarkerView
            view.configure(count: cluster.memberAnnotations.count)
            return view
        }

        if let place = annotation as? PlaceAnnotation {
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: PlaceAnnotationMarkerView.reuseID,
                for: place
            ) as! PlaceAnnotationMarkerView
            view.configure(with: place)
            return view
        }

        if let label = annotation as? HotPlaceLabelAnnotation {
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: HotPlaceLabelMarkerView.reuseID,
                for: label
            ) as! HotPlaceLabelMarkerView
            view.configure(with: label)
            return view
        }

        if let geoObject = annotation as? GeoObjectAnnotation {
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: GeoObject3DMarkerView.reuseID,
                for: geoObject
            ) as! GeoObject3DMarkerView
            view.configure(with: geoObject)
            return view
        }

        return nil
    }

    // MARK: Overlay Renderer (MKPolygon → fill + stroke)

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon,
           let id = polygon.title,
           let colors = overlayColors[id] {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.fillColor = colors.fill
            renderer.strokeColor = colors.stroke
            renderer.lineWidth = 4
            renderer.lineCap = .round
            renderer.lineJoin = .round
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    // MARK: Annotation 탭 → 콜백

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        if let place = view.annotation as? PlaceAnnotation {
            parent.onAnnotationTap(place.placeModel)
        }
    }
}

// MARK: - PlaceAnnotationMarkerView (MKAnnotationView, dequeue 재사용)

final class PlaceAnnotationMarkerView: MKAnnotationView {
    static let reuseID = "PlaceAnnotation"

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
        let titleHeight: CGFloat = 12
        let containerWidth: CGFloat = 80
        let totalHeight = pinHeight + spacing + titleHeight

        // 핀 이미지
        pinImageView.image = UIImage(named: "icon_map_pin")?.withRenderingMode(.alwaysTemplate)
        pinImageView.tintColor = .black
        pinImageView.contentMode = .scaleAspectFit
        pinImageView.frame = CGRect(
            x: (containerWidth - pinWidth) / 2,
            y: 0,
            width: pinWidth,
            height: pinHeight
        )
        addSubview(pinImageView)

        // SF Symbol 아이콘 (핀 원형 중앙)
        let iconSize: CGFloat = 13
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.frame = CGRect(
            x: (containerWidth - iconSize) / 2,
            y: (pinWidth / 2) - (iconSize / 2),
            width: iconSize,
            height: iconSize
        )
        addSubview(iconImageView)

        // 타이틀 라벨
        titleLabel.font = .systemFont(ofSize: 9)
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byClipping
        titleLabel.textColor = UIColor(named: "label_strong") ?? .label
        titleLabel.frame = CGRect(
            x: 0,
            y: pinHeight + spacing,
            width: containerWidth,
            height: titleHeight
        )
        addSubview(titleLabel)

        // 프레임 + 앵커 포인트 (핀 하단 꼭지점이 좌표에 위치하도록)
        frame = CGRect(x: 0, y: 0, width: containerWidth, height: totalHeight)
        // 핀 하단(y=pinHeight)이 좌표 → 뷰 센터(totalHeight/2)에서 아래로 이동
        centerOffset = CGPoint(x: 0, y: -(totalHeight / 2 - pinHeight))
    }

    func configure(with placeAnnotation: PlaceAnnotation) {
        let model = placeAnnotation.placeModel
        let config = UIImage.SymbolConfiguration(pointSize: 11)
        iconImageView.image = UIImage(
            systemName: model.iconName,
            withConfiguration: config
        )?.withRenderingMode(.alwaysTemplate)
        titleLabel.text = model.title
        clusteringIdentifier = "PlaceCluster"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = nil
    }
}

// MARK: - HotPlaceLabelMarkerView (MKAnnotationView, dequeue 재사용)

final class HotPlaceLabelMarkerView: MKAnnotationView {
    static let reuseID = "HotPlaceLabel"

    private let backgroundPill = UIView()
    private let label = UILabel()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupViews() {
        backgroundColor = .clear
        isUserInteractionEnabled = false

        backgroundPill.layer.cornerRadius = 10
        backgroundPill.clipsToBounds = true
        addSubview(backgroundPill)

        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        backgroundPill.addSubview(label)
    }

    func configure(with annotation: HotPlaceLabelAnnotation) {
        let hotPlace = annotation.hotPlace
        label.text = "\(hotPlace.emoji) \(hotPlace.name)"
        backgroundPill.backgroundColor = UIColor(hotPlace.color)

        label.sizeToFit()
        let hPad: CGFloat = 8
        let vPad: CGFloat = 4
        let pillWidth = label.frame.width + hPad * 2
        let pillHeight = label.frame.height + vPad * 2

        backgroundPill.frame = CGRect(x: 0, y: 0, width: pillWidth, height: pillHeight)
        label.frame = CGRect(x: hPad, y: vPad, width: label.frame.width, height: label.frame.height)

        frame.size = CGSize(width: pillWidth, height: pillHeight)
        centerOffset = .zero
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        backgroundPill.backgroundColor = nil
    }
}

// MARK: - PlaceClusterMarkerView (클러스터링 — 가까운 핀 묶음)

final class PlaceClusterMarkerView: MKAnnotationView {
    static let reuseID = "PlaceCluster"

    private let countLabel = UILabel()
    private let circle = UIView()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupViews() {
        backgroundColor = .clear

        let size: CGFloat = 36
        circle.frame = CGRect(x: 0, y: 0, width: size, height: size)
        circle.layer.cornerRadius = size / 2
        circle.backgroundColor = UIColor(red: 42/255, green: 100/255, blue: 246/255, alpha: 0.85) // Primary
        circle.layer.borderWidth = 2
        circle.layer.borderColor = UIColor.white.cgColor
        addSubview(circle)

        countLabel.font = .systemFont(ofSize: 13, weight: .bold)
        countLabel.textColor = .white
        countLabel.textAlignment = .center
        countLabel.frame = circle.bounds
        circle.addSubview(countLabel)

        frame = CGRect(x: 0, y: 0, width: size, height: size)
        centerOffset = .zero
    }

    func configure(count: Int) {
        countLabel.text = count > 99 ? "99+" : "\(count)"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        countLabel.text = nil
    }
}

// MARK: - MKCoordinateRegion 비교 (피드백 루프 방지)

private extension MKCoordinateRegion {
    func isApproximatelyEqual(to other: MKCoordinateRegion, epsilon: Double = 0.0001) -> Bool {
        abs(center.latitude - other.center.latitude) < epsilon &&
        abs(center.longitude - other.center.longitude) < epsilon &&
        abs(span.latitudeDelta - other.span.latitudeDelta) < epsilon &&
        abs(span.longitudeDelta - other.span.longitudeDelta) < epsilon
    }
}
