//
//  ScheduleView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct ScheduleView: View {
    var body: some View {
        VStack {
            Text("일정관리 화면")
                .font(.title)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("일정관리")
    }
}
