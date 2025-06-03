//
//  MyPageView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct MyPageView: View {
    var body: some View {
        VStack {
            Text("마이페이지 화면")
                .font(.title)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("마이페이지")
    }
}
