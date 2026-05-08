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

struct GeoObjectARView: View {
    @State private var statusText = "AR 준비 중"
    @State private var arrowText = "·"
    @State private var distanceText = "-- m"

    var body: some View {
        ZStack {
            GeoObjectARContainer(
                statusText: $statusText,
                arrowText: $arrowText,
                distanceText: $distanceText
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 8) {
                Text("GeoObject AR")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text(statusText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))

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
        }
    }
}

private struct GeoObjectARContainer: UIViewRepresentable {
    @Binding var statusText: String
    @Binding var arrowText: String
    @Binding var distanceText: String

    func makeCoordinator() -> Coordinator {
        Coordinator(
            statusText: $statusText,
            arrowText: $arrowText,
            distanceText: $distanceText
        )
    }

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        view.automaticallyConfigureSession = false
        view.contentScaleFactor = min(UIScreen.main.scale, 2)
        view.renderOptions.insert([
            .disableAREnvironmentLighting,
            .disableCameraGrain,
            .disableDepthOfField,
            .disableMotionBlur
        ])
        view.session.delegate = context.coordinator
        context.coordinator.sessionView = view
        context.coordinator.start(on: view)
        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.sessionView = uiView
        context.coordinator.statusText = $statusText
        context.coordinator.arrowText = $arrowText
        context.coordinator.distanceText = $distanceText
    }

    final class Coordinator: NSObject, ARSessionDelegate {
        var statusText: Binding<String>
        var arrowText: Binding<String>
        var distanceText: Binding<String>
        weak var sessionView: ARView?

        private var targetAnchor: AnchorEntity?
        private var targetWorldPosition: SIMD3<Float>?
        private var hasPlacedTarget = false
        private var isTrackingNormal = false
        private var lastOverlayUpdate = Date.distantPast
        private var updateSubscription: (any Cancellable)?
        private var currentStatusText = ""
        private var currentArrowText = ""
        private var currentDistanceText = ""
        private var occlusionStatus = "Depth OFF"

        private let targetForwardDistance: Float = 0.2
        private let cubeSize: Float = 0.08

        init(
            statusText: Binding<String>,
            arrowText: Binding<String>,
            distanceText: Binding<String>
        ) {
            self.statusText = statusText
            self.arrowText = arrowText
            self.distanceText = distanceText
            currentStatusText = statusText.wrappedValue
            currentArrowText = arrowText.wrappedValue
            currentDistanceText = distanceText.wrappedValue
        }

        func start(on view: ARView) {
            guard ARWorldTrackingConfiguration.isSupported else {
                setStatus("AR 월드 트래킹 미지원")
                return
            }

            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = []
            configuration.environmentTexturing = .none
            configuration.isLightEstimationEnabled = false

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
            setStatus("카메라를 천천히 움직여 AR 추적 시작 (\(occlusionStatus))")
        }

        func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
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
            guard updateSubscription == nil else { return }

            updateSubscription = view.scene.subscribe(to: SceneEvents.Update.self) { [weak self, weak view] _ in
                guard let self, let view, self.isTrackingNormal else { return }
                self.placeTargetIfNeeded(on: view)
                self.updateOverlay(on: view)
            }
        }

        private func placeTargetIfNeeded(on view: ARView) {
            guard !hasPlacedTarget else { return }

            let cameraTransform = view.cameraTransform.matrix
            let targetVectorFromCamera = SIMD4<Float>(0, 0, -targetForwardDistance, 1)
            let worldPosition4 = cameraTransform * targetVectorFromCamera
            let worldPosition = SIMD3<Float>(worldPosition4.x, worldPosition4.y, worldPosition4.z)

            let anchor = AnchorEntity(world: worldPosition)
            let mesh = MeshResource.generateBox(size: cubeSize)
            let material = SimpleMaterial(color: .red, isMetallic: false)
            let cube = ModelEntity(mesh: mesh, materials: [material])
            cube.position = SIMD3<Float>(0, cubeSize / 2, 0)

            anchor.addChild(cube)
            view.scene.addAnchor(anchor)

            targetAnchor = anchor
            targetWorldPosition = worldPosition
            hasPlacedTarget = true
            setStatus("빨간 큐브 배치됨: 카메라 앞 20cm (\(occlusionStatus))")
        }

        private func updateOverlay(on view: ARView) {
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
            guard currentStatusText != status else { return }
            currentStatusText = status

            DispatchQueue.main.async { [weak self] in
                self?.statusText.wrappedValue = status
            }
        }

        private func setArrow(_ arrow: String) {
            guard currentArrowText != arrow else { return }
            currentArrowText = arrow

            DispatchQueue.main.async { [weak self] in
                self?.arrowText.wrappedValue = arrow
            }
        }

        private func setDistance(_ distance: String) {
            guard currentDistanceText != distance else { return }
            currentDistanceText = distance

            DispatchQueue.main.async { [weak self] in
                self?.distanceText.wrappedValue = distance
            }
        }
    }
}
