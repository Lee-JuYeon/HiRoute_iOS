//
//  ARObjectTestContainer.swift
//  HiRoute
//
//  Created by Codex on 5/7/26.
//

import UIKit
import ARKit
import RealityKit
import SwiftUI

// SwiftUI 안에 RealityKit ARView를 붙이기 위한 래퍼.
struct ARObjectTestContainer: UIViewRepresentable {
    @Binding var statusText: String

    // AR 세션 이벤트를 받을 coordinator를 만든다.
    func makeCoordinator() -> Coordinator {
        Coordinator(statusText: $statusText)
    }

    // UIKit AR 뷰 생성.
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        // ARView의 자동 세션 설정이 detectionImages를 덮어쓰지 못하게 막는다.
        view.automaticallyConfigureSession = false
        view.renderOptions.insert([
            .disableAREnvironmentLighting,
            .disableCameraGrain,
            .disableDepthOfField,
            .disableMotionBlur,
            .disablePersonOcclusion
        ])
        view.session.delegate = context.coordinator

        // 세션 설정 시작.
        context.coordinator.configureSession(on: view)
        return view
    }

    // SwiftUI 갱신 시 현재 AR 뷰 참조를 coordinator에 넘긴다.
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.sessionView = uiView
        context.coordinator.statusText = $statusText
    }

    // AR 세션과 이미지 인식을 담당한다.
    final class Coordinator: NSObject, ARSessionDelegate {
        var statusText: Binding<String>
        // 현재 연결된 AR 뷰.
        weak var sessionView: ARView?
        private var markerEntity: AnchorEntity?
        private var hasPlacedMarkerObject = false
        private var markerLostWorkItem: DispatchWorkItem?
        // 실물 마커 이름.
        private let markerImageName = "nunulala_marker"
        // 인식 이미지의 실제 물리 폭(m).
        private let markerPhysicalWidth: CGFloat = 0.16

        init(statusText: Binding<String>) {
            self.statusText = statusText
        }

        // 에셋에 넣은 실물 마커를 ARReferenceImage로 등록한다.
        private lazy var referenceImages: Set<ARReferenceImage> = {
            guard let image = UIImage(named: markerImageName) else {
                print("ARObjectTest // marker asset missing:", markerImageName)
                return []
            }
            guard let cgImage = image.cgImage else {
                print("ARObjectTest // marker cgImage missing:", markerImageName)
                return []
            }
            print(
                "ARObjectTest // marker asset loaded:",
                markerImageName,
                "pixels=\(cgImage.width)x\(cgImage.height)",
                "scale=\(image.scale)",
                "orientation=\(image.imageOrientation.rawValue)"
            )
            let reference = ARReferenceImage(cgImage, orientation: .up, physicalWidth: markerPhysicalWidth)
            reference.name = markerImageName
            return [reference]
        }()

        // 이미지 인식이 포함된 AR 세션을 시작한다.
        func configureSession(on view: ARView) {
            sessionView = view
            guard ARWorldTrackingConfiguration.isSupported else { return }
            startSession(on: view)
        }

        // 이전에 실제 감지가 확인된 월드 트래킹 기반 이미지 인식 설정.
        private func startSession(on view: ARView) {
            setStatus("마커 찾는 중")
            for reference in referenceImages {
                reference.validate { error in
                    if let error {
                        print("ARObjectTest // referenceImage invalid:", error)
                    } else {
                        print(
                            "ARObjectTest // referenceImage valid:",
                            reference.name ?? "nil",
                            "physicalWidth=\(reference.physicalSize.width)"
                        )
                    }
                }
            }

            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = []
            configuration.environmentTexturing = .none
            configuration.isLightEstimationEnabled = false
            configuration.maximumNumberOfTrackedImages = 1
            configuration.detectionImages = referenceImages.isEmpty ? nil : referenceImages

            print(
                "ARObjectTest // directConfig type=",
                type(of: configuration),
                "imageCount=",
                referenceImages.count
            )
            print("ARObjectTest // config worldTracking imageDetectionOnly")

            view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let activeConfiguration = view.session.configuration as? ARWorldTrackingConfiguration {
                    print(
                        "ARObjectTest // activeConfig detectionImagesCount=",
                        activeConfiguration.detectionImages?.count ?? 0,
                        "autoConfig=\(view.automaticallyConfigureSession)"
                    )
                } else {
                    print("ARObjectTest // activeConfig unknown autoConfig=\(view.automaticallyConfigureSession)")
                }
            }
        }

        // AR 이미지가 감지되면 RealityKit 엔티티를 붙인다.
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                print("ARObjectTest // didAdd:", type(of: anchor))
                guard let imageAnchor = anchor as? ARImageAnchor else { continue }
                markMarkerVisible()
                print(
                    "ARObjectTest // imageAnchor detected:",
                    imageAnchor.referenceImage.name ?? "nil",
                    "physicalSize=\(imageAnchor.referenceImage.physicalSize)"
                )
                addDebugObject(for: imageAnchor)
            }
        }

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                guard let imageAnchor = anchor as? ARImageAnchor else { continue }
                if imageAnchor.isTracked {
                    markMarkerVisible()
                } else {
                    setStatus("마커 찾는 중")
                }
            }
        }

        // 인식 성공 여부를 바로 볼 수 있는 최소 테스트 오브젝트.
        private func addDebugObject(for imageAnchor: ARImageAnchor) {
            DispatchQueue.main.async { [weak self] in
                guard let self, let sessionView else { return }
                guard !hasPlacedMarkerObject else {
                    markerEntity?.transform.matrix = imageAnchor.transform
                    return
                }

                let anchorEntity = AnchorEntity(world: imageAnchor.transform)
                let markerSize = imageAnchor.referenceImage.physicalSize
                let planeMesh = MeshResource.generatePlane(
                    width: Float(markerSize.width),
                    depth: Float(markerSize.height)
                )
                let planeMaterial = SimpleMaterial(
                    color: UIColor.red.withAlphaComponent(0.45),
                    isMetallic: false
                )
                let plane = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
                plane.position = SIMD3<Float>(0, 0.002, 0)

                let mesh = MeshResource.generateBox(size: 0.12)
                let material = SimpleMaterial(color: .red, isMetallic: false)
                let model = ModelEntity(mesh: mesh, materials: [material])
                model.position = SIMD3<Float>(0, 0.08, 0)

                anchorEntity.addChild(plane)
                anchorEntity.addChild(model)
                sessionView.scene.addAnchor(anchorEntity)
                markerEntity = anchorEntity
                hasPlacedMarkerObject = true
                markMarkerVisible()
                print("ARObjectTest // reality object added")
            }
        }

        private func markMarkerVisible() {
            markerLostWorkItem?.cancel()
            setStatus("마커 인식됨")

            let workItem = DispatchWorkItem { [weak self] in
                self?.setStatus("마커 찾는 중")
            }
            markerLostWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: workItem)
        }

        private func setStatus(_ status: String) {
            DispatchQueue.main.async { [weak self] in
                guard let self, self.statusText.wrappedValue != status else { return }
                self.statusText.wrappedValue = status
            }
        }
    }
}
