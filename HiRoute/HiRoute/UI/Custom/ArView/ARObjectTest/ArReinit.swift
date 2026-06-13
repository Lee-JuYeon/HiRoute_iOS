//
//  ArReinit.swift
//  HiRoute
//
//  Created by Codex on 5/7/26.
//

import ARKit
import UIKit

// 월드맵이 꼬였을 때 세션을 초기 상태로 되돌리는 헬퍼.
final class ArReinit {
    // 저장된 월드맵 파일을 삭제하고 세션을 멈춘다.
    func resetSession(on view: ARSCNView, savedWorldMapURL: URL?) {
        if let savedWorldMapURL {
            try? FileManager.default.removeItem(at: savedWorldMapURL)
        }

        view.session.pause()
    }
}
