//
//  HomePlaceTitle.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import SwiftUI

struct ElevationModifier: ViewModifier {
    let level: Elevation
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        Group {
            if colorScheme == .dark {
                // 다크모드: 흰색 그림자 + 더 높은 투명도
//                content.shadow(color: .white.opacity(0.1), radius: shadowRadius, x: 0, y: shadowY)
                content.shadow(color: .white.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: shadowY)
            } else {
                // 라이트모드: 검은색 그림자
                content.shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: shadowY)
            }
        }
    }
    
    private var shadowOpacity: Double {
        switch level {
        case .normal: return 0.2
        case .emphasize: return 0.25
        case .strong: return 0.3
        case .heavy: return 0.4
        }
    }
    
    private var shadowRadius: CGFloat {
        switch level {
        case .normal: return 2 * 1.5
        case .emphasize: return 4 * 1.5
        case .strong: return 6 * 1.5
        case .heavy: return 10 * 1.5
        }
    }
    
    private var shadowY: CGFloat {
        switch level {
        case .normal: return 1 * 1.5
        case .emphasize: return 2 * 1.5
        case .strong: return 3 * 1.5
        case .heavy: return 5 * 1.5
        }
    }
}
