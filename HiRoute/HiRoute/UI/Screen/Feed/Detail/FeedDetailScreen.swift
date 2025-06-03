//
//  FeedDetailScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct FeedDetailScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("피드 상세보기")
                    .font(.title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("피드 상세")
            .navigationBarItems(trailing: Button("완료") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
