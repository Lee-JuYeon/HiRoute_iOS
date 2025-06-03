//
//  FeedView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct FeedView: View {
    let onNavigateToFeedCreate: () -> Void
    let onNavigateToFeedDetail: () -> Void
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        VStack {
            // 헤더
            HStack {
                Text("일정 피드")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button("피드 관리") {
                        // Feed management logic
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
                    
                    Button("🔔") {
                        // Notification logic
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
                    
                    Button(action: onNavigateToFeedCreate) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(4)
                }
            }
            .padding()
            
            // 피드 그리드
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(sampleFeedItems, id: \.id) { item in
                        Button(action: onNavigateToFeedDetail) {
                            FeedItemCard(item: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
        .navigationTitle("일정피드")
    }
}


