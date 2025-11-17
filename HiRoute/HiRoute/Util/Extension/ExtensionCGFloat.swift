//
//  EventListView.swift
//  HiRoute
//
//  Created by Jupond on 7/1/25.
//
import SwiftUI

extension CGFloat {
    var px: CGFloat { // 피그마 px을 swiftui pt에 반영
        return self / UIScreen.main.scale  // 디바이스 스케일 기준
    }
}
