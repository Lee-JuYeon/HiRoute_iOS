//
//  GeoObjectARView.swift
//  HiRoute
//
//  Created by Codex on 5/7/26.
//

import ARKit
import Combine
import RealityKit
import SwiftUI

// GeoObject AR 테스트용 화면이다.
// 지금은 서버 모델 대신 번들에 들어 있는 red_cube.usdz를 월드 공간에 배치한다.
struct GeoObjectARView: View {
    // AR 상태, 방향 화살표, 거리, 바텀시트 표시 여부는 SwiftUI 상태로 관리한다.
    @State private var statusText = "AR 준비 중"
    @State private var arrowText = "·"
    @State private var distanceText = "-- m"
    @State private var assetStatusText = "오브젝트 미다운로드"
    @State private var isCubeSheetPresented = false
    @State private var localAsset: QuestAssetDTO?
    @State private var clearRenderToken = 0
    @State private var isAssetBusy = false

    var body: some View {
        ZStack {
            // UIKit/RealityKit 기반 ARView를 SwiftUI 화면 안에 넣는 래퍼다.
            GeoObjectARContainer(
                statusText: $statusText,
                arrowText: $arrowText,
                distanceText: $distanceText,
                isCubeSheetPresented: $isCubeSheetPresented,
                localAsset: localAsset,
                clearRenderToken: clearRenderToken
            )
            .ignoresSafeArea()

            // 좌상단 디버그 HUD다. 현재 AR 상태와 큐브 방향/거리를 보여준다.
            VStack(alignment: .leading, spacing: 8) {
                Text("GeoObject AR")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text(statusText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))

                Text(assetStatusText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.82))

                HStack(spacing: 10) {
                    Text(arrowText)
                        .font(.system(size: 36, weight: .bold))
                        .frame(width: 52, height: 52)
                        .background(Color.black.opacity(0.72))
                        .clipShape(Circle())

                    Text(distanceText)
                        .font(.system(size: 18, weight: .bold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.72))
                        .clipShape(Capsule())
                }
                .foregroundColor(.white)
            }
            .padding(.leading, 20)
            .padding(.top, 64)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .shadow(color: .black.opacity(0.45), radius: 8, x: 0, y: 4)
            .allowsHitTesting(false)

            assetControlPanel

            // 큐브를 탭하면 올라오는 테스트용 바텀시트다.
            if isCubeSheetPresented {
                cubeBottomSheet
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.86), value: isCubeSheetPresented)
        .onAppear {
            loadDownloadedAsset()
        }
    }

    // 서버 다운로드가 붙기 전까지는 번들 usdz를 "다운로드된 파일"처럼 Application Support에 복사해서 테스트한다.
    private var assetControlPanel: some View {
        HStack(spacing: 10) {
            Button {
                downloadTestAsset()
            } label: {
                Label("다운로드", systemImage: "arrow.down.circle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(Color.blue.opacity(localAsset == nil ? 0.88 : 0.45))
                    .clipShape(Capsule())
            }
            .disabled(isAssetBusy || localAsset != nil)

            Button {
                deleteDownloadedAsset()
            } label: {
                Image(systemName: "trash.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.red.opacity(localAsset == nil ? 0.35 : 0.88))
                    .clipShape(Circle())
            }
            .disabled(isAssetBusy || localAsset == nil)
        }
        .padding(.trailing, 18)
        .padding(.top, 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }

    // 실제 서비스에서는 서버에서 받은 오브젝트 정보를 이 시트에 표시하면 된다.
    private var cubeBottomSheet: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(Color.white.opacity(0.35))
                .frame(width: 42, height: 5)
                .padding(.top, 10)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Red Cube")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text("이건 레드큐브 입니다.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.92))
                }

                Spacer()

                Button {
                    isCubeSheetPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.16))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.black.opacity(0.86))
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private func loadDownloadedAsset() {
        QuestAssetStore.shared.readAsset(assetId: testAsset.assetId) { asset in
            DispatchQueue.main.async {
                guard let asset,
                      QuestAssetStore.shared.localFileURL(for: asset) != nil else {
                    localAsset = nil
                    assetStatusText = "오브젝트 미다운로드"
                    return
                }

                localAsset = asset
                assetStatusText = "로컬 DTO 로드 완료"
            }
        }
    }

    private func downloadTestAsset() {
        guard !isAssetBusy else { return }
        isAssetBusy = true
        assetStatusText = "다운로드 중"

        DispatchQueue.global(qos: .utility).async {
            do {
                guard let bundleURL = Bundle.main.url(forResource: "red_cube", withExtension: "usdz") else {
                    throw GeoObjectAssetError.bundleAssetMissing
                }

                let data = try Data(contentsOf: bundleURL)
                QuestAssetStore.shared.saveDownloadedAsset(data: data, asset: testAsset) { result in
                    DispatchQueue.main.async {
                        isAssetBusy = false

                        switch result {
                        case .success(let asset):
                            localAsset = asset
                            assetStatusText = "다운로드 완료: 로컬 렌더링"
                        case .failure:
                            localAsset = nil
                            assetStatusText = "다운로드 실패"
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isAssetBusy = false
                    assetStatusText = "다운로드 실패"
                }
            }
        }
    }

    private func deleteDownloadedAsset() {
        guard let localAsset, !isAssetBusy else { return }
        isAssetBusy = true
        assetStatusText = "삭제 중"

        QuestAssetStore.shared.deleteAsset(localAsset) { success in
            DispatchQueue.main.async {
                isAssetBusy = false
                isCubeSheetPresented = false
                self.localAsset = nil
                clearRenderToken += 1
                assetStatusText = success ? "오브젝트 삭제 완료" : "오브젝트 삭제 실패"
            }
        }
    }

    private var testAsset: QuestAssetDTO {
        QuestAssetDTO(
            assetId: "red_cube",
            questId: "geo_object_test",
            name: "Red Cube",
            assetType: .model3D,
            remoteURL: "bundle://red_cube.usdz",
            localRelativePath: nil,
            fileHash: nil,
            fileSize: 0,
            mimeType: "model/vnd.usdz+zip",
            duration: nil,
            latitude: 0,
            longitude: 0,
            altitude: 0,
            animationName: nil,
            isDownloaded: false,
            downloadedAt: nil,
            updatedAt: Date()
        )
    }
}

private enum GeoObjectAssetError: Error {
    case bundleAssetMissing
}

// ARView는 UIKit 뷰이기 때문에 SwiftUI에서 쓰려면 UIViewRepresentable로 감싸야 한다.
private struct GeoObjectARContainer: UIViewRepresentable {
    // Coordinator에서 SwiftUI 상태를 변경할 수 있도록 Binding을 넘긴다.
    @Binding var statusText: String
    @Binding var arrowText: String
    @Binding var distanceText: String
    @Binding var isCubeSheetPresented: Bool
    let localAsset: QuestAssetDTO?
    let clearRenderToken: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(
            statusText: $statusText,
            arrowText: $arrowText,
            distanceText: $distanceText,
            isCubeSheetPresented: $isCubeSheetPresented,
            localAsset: localAsset,
            clearRenderToken: clearRenderToken
        )
    }

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        // 자동 세션 구성을 끄고 우리가 직접 ARWorldTrackingConfiguration을 넣는다.
        view.automaticallyConfigureSession = false
        // 렌더 해상도를 과하게 높이지 않아 실기기 부하를 줄인다.
        view.contentScaleFactor = min(UIScreen.main.scale, 2)
        // 테스트 화면에서는 필요 없는 후처리/환경 효과를 끄고 가볍게 유지한다.
        view.renderOptions.insert([
            .disableAREnvironmentLighting,
            .disableCameraGrain,
            .disableDepthOfField,
            .disableMotionBlur
        ])
        view.session.delegate = context.coordinator
        context.coordinator.sessionView = view
        context.coordinator.start(on: view)
        context.coordinator.installTapGesture(on: view)
        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // SwiftUI가 상태를 다시 그릴 때 Coordinator가 최신 Binding을 보게 한다.
        context.coordinator.sessionView = uiView
        context.coordinator.statusText = $statusText
        context.coordinator.arrowText = $arrowText
        context.coordinator.distanceText = $distanceText
        context.coordinator.isCubeSheetPresented = $isCubeSheetPresented
        context.coordinator.updateAsset(localAsset)
        context.coordinator.clearRenderedAssetIfNeeded(token: clearRenderToken)
    }

    // AR 세션 이벤트, 모델 배치, 탭 처리, HUD 갱신을 담당하는 UIKit 쪽 객체다.
    final class Coordinator: NSObject, ARSessionDelegate {
        var statusText: Binding<String>
        var arrowText: Binding<String>
        var distanceText: Binding<String>
        var isCubeSheetPresented: Binding<Bool>
        weak var sessionView: ARView?
        private var localAsset: QuestAssetDTO?
        private var clearRenderToken: Int

        private var targetAnchor: AnchorEntity?
        private weak var targetEntity: Entity?
        private var targetWorldPosition: SIMD3<Float>?
        private var hasPlacedTarget = false
        private var isTrackingNormal = false
        private var lastOverlayUpdate = Date.distantPast
        private var updateSubscription: (any Cancellable)?
        private var openAnimationController: AnimationPlaybackController?
        private var currentStatusText = ""
        private var currentArrowText = ""
        private var currentDistanceText = ""
        private var occlusionStatus = "Depth OFF"

        // USDZ 내부 엔티티와 탭 hit-test에서 같은 오브젝트인지 판별하기 위한 이름이다.
        private let targetEntityName = "geo_object_red_cube"
        private let targetForwardDistance: Float = 0.2
        private let cubeSize: Float = 0.08

        init(
            statusText: Binding<String>,
            arrowText: Binding<String>,
            distanceText: Binding<String>,
            isCubeSheetPresented: Binding<Bool>,
            localAsset: QuestAssetDTO?,
            clearRenderToken: Int
        ) {
            self.statusText = statusText
            self.arrowText = arrowText
            self.distanceText = distanceText
            self.isCubeSheetPresented = isCubeSheetPresented
            self.localAsset = localAsset
            self.clearRenderToken = clearRenderToken
            currentStatusText = statusText.wrappedValue
            currentArrowText = arrowText.wrappedValue
            currentDistanceText = distanceText.wrappedValue
        }

        func start(on view: ARView) {
            // ARWorldTrackingConfiguration은 카메라 움직임으로 월드 좌표를 추적하는 설정이다.
            guard ARWorldTrackingConfiguration.isSupported else {
                setStatus("AR 월드 트래킹 미지원")
                return
            }

            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = []
            configuration.environmentTexturing = .none
            configuration.isLightEstimationEnabled = false

            // depth를 지원하는 기기에서만 사람/손 occlusion을 켠다.
            // 미지원 기기에서 강제로 켜면 성능/동작 문제가 생길 수 있다.
            if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
                configuration.frameSemantics.insert(.personSegmentationWithDepth)
                view.renderOptions.remove(.disablePersonOcclusion)
                occlusionStatus = "Depth ON"
            } else {
                view.renderOptions.insert(.disablePersonOcclusion)
                occlusionStatus = "Depth OFF"
            }

            view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            subscribeToSceneUpdates(on: view)
            setStatus(localAsset == nil ? "오브젝트 다운로드 필요 (\(occlusionStatus))" : "카메라를 천천히 움직여 AR 추적 시작 (\(occlusionStatus))")
        }

        func updateAsset(_ asset: QuestAssetDTO?) {
            let oldAssetId = localAsset?.assetId
            localAsset = asset

            guard oldAssetId != asset?.assetId else { return }

            removeRenderedTarget()

            if asset == nil {
                setStatus("오브젝트 다운로드 필요 (\(occlusionStatus))")
            } else {
                setStatus("로컬 DTO 확인: 렌더링 준비 (\(occlusionStatus))")
            }
        }

        func clearRenderedAssetIfNeeded(token: Int) {
            guard clearRenderToken != token else { return }
            clearRenderToken = token
            removeRenderedTarget()
            setArrow("·")
            setDistance("-- m")
            setStatus("오브젝트 삭제됨")
        }

        func installTapGesture(on view: ARView) {
            // updateUIView가 여러 번 호출돼도 탭 제스처가 중복 등록되지 않게 이름으로 검사한다.
            guard view.gestureRecognizers?.contains(where: { $0.name == "geo_object_cube_tap" }) != true else {
                return
            }

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tapGesture.name = "geo_object_cube_tap"
            view.addGestureRecognizer(tapGesture)
        }

        func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            // normal이 되기 전에는 월드 좌표가 불안정하므로 큐브를 배치하지 않는다.
            switch camera.trackingState {
            case .normal:
                isTrackingNormal = true
                setStatus(hasPlacedTarget ? "빨간 큐브 추적 중 (\(occlusionStatus))" : "AR 추적 정상: 큐브 배치 준비 (\(occlusionStatus))")
            case .limited:
                isTrackingNormal = false
                setStatus("AR 추적 보정 중")
            case .notAvailable:
                isTrackingNormal = false
                setStatus("AR 추적 불가")
            }
        }

        private func subscribeToSceneUpdates(on view: ARView) {
            // SceneEvents.Update는 RealityKit의 매 프레임 업데이트 이벤트다.
            // 여기서는 최초 큐브 배치와 방향/거리 HUD 갱신에만 사용한다.
            guard updateSubscription == nil else { return }

            updateSubscription = view.scene.subscribe(to: SceneEvents.Update.self) { [weak self, weak view] _ in
                guard let self, let view, self.isTrackingNormal else { return }
                self.placeTargetIfNeeded(on: view)
                self.updateOverlay(on: view)
            }
        }

        private func placeTargetIfNeeded(on view: ARView) {
            // 테스트용 큐브는 한 번만 배치한다.
            guard !hasPlacedTarget else { return }
            guard let localAsset else { return }

            // 카메라 기준 정면 20cm 지점을 월드 좌표로 변환한다.
            let cameraTransform = view.cameraTransform.matrix
            let targetVectorFromCamera = SIMD4<Float>(0, 0, -targetForwardDistance, 1)
            let worldPosition4 = cameraTransform * targetVectorFromCamera
            let worldPosition = SIMD3<Float>(worldPosition4.x, worldPosition4.y, worldPosition4.z)

            guard let cube = loadRedCubeEntity(from: localAsset) else {
                setStatus("로컬 red_cube.usdz 로드 실패")
                return
            }

            let anchor = AnchorEntity(world: worldPosition)
            anchor.addChild(cube)
            view.scene.addAnchor(anchor)

            targetAnchor = anchor
            targetEntity = cube
            targetWorldPosition = worldPosition
            hasPlacedTarget = true
            setStatus("로컬 USDZ 렌더링 완료: 카메라 앞 20cm (\(occlusionStatus))")
        }

        private func loadRedCubeEntity(from asset: QuestAssetDTO) -> Entity? {
            // CoreData DTO의 상대경로를 Application Support 실제 파일 URL로 바꿔 로드한다.
            guard let modelURL = QuestAssetStore.shared.localFileURL(for: asset) else {
                return nil
            }

            do {
                let entity = try Entity.load(contentsOf: modelURL)
                entity.name = targetEntityName
                entity.scale = SIMD3<Float>(repeating: cubeSize)
                entity.position = SIMD3<Float>(0, cubeSize / 2, 0)
                entity.generateCollisionShapes(recursive: true)
                return entity
            } catch {
                return nil
            }
        }

        private func removeRenderedTarget() {
            targetAnchor?.removeFromParent()
            targetAnchor = nil
            targetEntity = nil
            targetWorldPosition = nil
            hasPlacedTarget = false
            openAnimationController?.stop()
            openAnimationController = nil
        }

        @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
            // ARView의 화면 좌표에서 collision이 있는 엔티티를 찾는다.
            guard let view = gesture.view as? ARView else { return }

            let tapLocation = gesture.location(in: view)
            guard let tappedEntity = view.entity(at: tapLocation),
                  isTargetEntity(tappedEntity) else {
                return
            }

            setCubeSheetPresented(true)
            playOpenAnimation()
        }

        private func isTargetEntity(_ entity: Entity) -> Bool {
            // USDZ는 내부에 여러 child node를 가질 수 있으므로 부모를 타고 올라가며 검사한다.
            var current: Entity? = entity

            while let entity = current {
                if entity.name == targetEntityName || entity === targetEntity {
                    return true
                }

                current = entity.parent
            }

            return false
        }

        private func playOpenAnimation() {
            // 실제 서비스 구조에서는 USDZ 내부에 애니메이션을 넣어두고,
            // iOS는 availableAnimations에서 꺼내 재생만 한다.
            guard let targetEntity else { return }

            if playFirstAvailableAnimation(in: targetEntity) {
                setStatus("레드큐브 열림 애니메이션 재생")
            } else {
                setStatus("red_cube.usdz 애니메이션 없음")
            }
        }

        private func playFirstAvailableAnimation(in entity: Entity) -> Bool {
            if let animation = entity.availableAnimations.first {
                openAnimationController?.stop()
                openAnimationController = entity.playAnimation(
                    animation,
                    transitionDuration: 0.15,
                    startsPaused: false
                )
                return true
            }

            // USDZ 내부 구조에 따라 animation이 child entity에 붙어 있을 수 있어서 재귀 탐색한다.
            for child in entity.children where playFirstAvailableAnimation(in: child) {
                return true
            }

            return false
        }

        private func updateOverlay(on view: ARView) {
            // 카메라와 큐브 사이 거리/방향을 계산해서 HUD에 표시한다.
            guard let targetWorldPosition else { return }

            let now = Date()
            guard now.timeIntervalSince(lastOverlayUpdate) > 0.08 else { return }
            lastOverlayUpdate = now

            let cameraTransform = view.cameraTransform.matrix
            let cameraPosition = view.cameraTransform.translation
            let worldDelta = targetWorldPosition - cameraPosition
            let distance = simd_length(worldDelta)

            let cameraSpaceTarget = cameraTransform.inverse * SIMD4<Float>(
                targetWorldPosition.x,
                targetWorldPosition.y,
                targetWorldPosition.z,
                1
            )
            let arrow = arrow(for: cameraSpaceTarget)

            setArrow(arrow)
            setDistance(String(format: "%.2f m", distance))
        }

        private func arrow(for cameraSpaceTarget: SIMD4<Float>) -> String {
            // 월드 좌표를 카메라 로컬 좌표로 바꾼 뒤, x/y/z 값으로 대략적인 방향을 표시한다.
            let x = cameraSpaceTarget.x
            let y = cameraSpaceTarget.y
            let z = cameraSpaceTarget.z

            if z > 0 {
                return "↓"
            }

            if abs(x) < 0.04 && abs(y) < 0.04 {
                return "↑"
            }

            if abs(x) > abs(y) {
                return x > 0 ? "→" : "←"
            }

            return y > 0 ? "↗" : "↘"
        }

        private func setStatus(_ status: String) {
            // 같은 문자열을 매 프레임 다시 넣지 않도록 캐시해서 SwiftUI 업데이트를 줄인다.
            guard currentStatusText != status else { return }
            currentStatusText = status

            DispatchQueue.main.async { [weak self] in
                self?.statusText.wrappedValue = status
            }
        }

        private func setArrow(_ arrow: String) {
            // 화살표도 값이 바뀔 때만 SwiftUI 상태를 갱신한다.
            guard currentArrowText != arrow else { return }
            currentArrowText = arrow

            DispatchQueue.main.async { [weak self] in
                self?.arrowText.wrappedValue = arrow
            }
        }

        private func setDistance(_ distance: String) {
            // 거리 문자열도 값이 바뀔 때만 갱신해서 렌더 부하를 낮춘다.
            guard currentDistanceText != distance else { return }
            currentDistanceText = distance

            DispatchQueue.main.async { [weak self] in
                self?.distanceText.wrappedValue = distance
            }
        }

        private func setCubeSheetPresented(_ isPresented: Bool) {
            // UIKit 제스처 콜백에서 SwiftUI 상태를 바꾸므로 메인 큐에서 처리한다.
            DispatchQueue.main.async { [weak self] in
                self?.isCubeSheetPresented.wrappedValue = isPresented
            }
        }
    }
}
