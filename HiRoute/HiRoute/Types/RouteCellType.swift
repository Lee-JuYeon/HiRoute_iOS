//
//  RouteCellType.swift
//  HiRoute
//
//  Created by Jupond on 7/30/25.
//
import Foundation
import UIKit
import SwiftUI

enum RouteCellType {
    case trendingRoute
    case localisedRoute
    
    var width: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 32 // 좌우 16씩
        let spacing: CGFloat = 16 // 아이템 간 간격
        
        switch self {
        case .trendingRoute:
            let itemCount: CGFloat = 3
            let totalSpacing = spacing * (itemCount - 1)
            return (screenWidth - padding - totalSpacing) / itemCount
        case .localisedRoute:
            let itemCount: CGFloat = 2
            let totalSpacing = spacing * (itemCount - 1)
            return (screenWidth - padding - totalSpacing) / itemCount
        }
    }
    
    var height: CGFloat {
        switch self {
        case .trendingRoute:
            return 200
        case .localisedRoute:
            return 260
        }
    }
    
    var imageHeight: CGFloat {
        switch self {
        case .trendingRoute:
            return 120
        case .localisedRoute:
            return 164
        }
    }
    
    var bookmarkOffset: (x: CGFloat, y: CGFloat) {
        switch self {
        case .trendingRoute:
            return (-8, 8)
        case .localisedRoute:
            return (-11.5, 12)
        }
    }
    
    var categoryFontSize: CGFloat {
        switch self {
        case .trendingRoute:
            return 12
        case .localisedRoute:
            return 14
        }
    }
    
    var titleFontSize: CGFloat {
        switch self {
        case .trendingRoute:
            return 14
        case .localisedRoute:
            return 16
        }
    }
    
    var infoFontSize: CGFloat {
        switch self {
        case .trendingRoute:
            return 12
        case .localisedRoute:
            return 14
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .trendingRoute:
            return 8
        case .localisedRoute:
            return 12
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .trendingRoute:
            return 12
        case .localisedRoute:
            return 16
        }
    }
    
    var categoryColor: Color {
        switch self {
        case .trendingRoute:
            return Color.getColour(.label_alternative)
        case .localisedRoute:
            return Color("text_lightgray")
        }
    }
    
    var titleColor: Color {
        switch self {
        case .trendingRoute:
            return Color.getColour(.label_normal)
        case .localisedRoute:
            return Color.black
        }
    }
    
    var infoColor: Color {
        switch self {
        case .trendingRoute:
            return Color.getColour(.label_neutral)
        case .localisedRoute:
            return Color.black
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .trendingRoute:
            return Color.getColour(.background_white)
        case .localisedRoute:
            return Color.white
        }
    }
    
    var contentSpacing: CGFloat {
        switch self {
        case .trendingRoute:
            return 2
        case .localisedRoute:
            return 4
        }
    }
    
    var needsSpacer: Bool {
        switch self {
        case .trendingRoute:
            return true
        case .localisedRoute:
            return false
        }
    }
    
    var hasBookmarkElevation: Bool {
        switch self {
        case .trendingRoute:
            return false
        case .localisedRoute:
            return true // HomePlaceCell에서만 북마크에 elevation 있음
        }
    }
}
