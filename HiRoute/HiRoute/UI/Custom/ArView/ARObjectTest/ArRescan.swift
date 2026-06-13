//
//  ArRescan.swift
//  HiRoute
//
//  Created by Codex on 5/7/26.
//

import ARKit
import UIKit

// AR 세션을 새로 여는 헬퍼.
final class ArRescan {
    func run(
        on view: ARSCNView,
        detectionImages: Set<ARReferenceImage>
    ) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        configuration.isLightEstimationEnabled = true
        configuration.maximumNumberOfTrackedImages = 1
        configuration.detectionImages = detectionImages.isEmpty ? nil : detectionImages

        view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}
