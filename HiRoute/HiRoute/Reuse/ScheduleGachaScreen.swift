//
//  ScheduleGachaScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct ScheduleGachaScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("일정 뽑기")
                    .font(.title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("일정 뽑기")
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("완료") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
