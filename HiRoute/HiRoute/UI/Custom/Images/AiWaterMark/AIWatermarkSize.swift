//
//  AIWatermarkSize.swift
//  HiRoute
//
//  Created by Jupond on 3/13/26.
//
import Foundation

enum AIWatermarkSize {
    case thumbnail
    case normal

    var iconSize: CGFloat {
        switch self {
        case .thumbnail: return 12
        case .normal: return 16
        }
    }

    var backgroundSize: CGFloat {
        switch self {
        case .thumbnail: return 20
        case .normal: return 28
        }
    }

    var padding: CGFloat {
        switch self {
        case .thumbnail: return 2
        case .normal: return 6
        }
    }
}
