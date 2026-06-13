//
//  HomeView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI

/// 지도 탭 화면. 실제 맵 컨텐츠는 `HomeMapContent`로 분리되어 fullScreenCover 등에서도 재사용 가능.
struct HomeView: View {
    var body: some View {
        HomeMapContent()
    }
}
