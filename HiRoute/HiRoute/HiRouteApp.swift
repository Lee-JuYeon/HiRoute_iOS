//
//  HiRouteApp.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI

@main
struct HiRouteApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AppNavigationView()

//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}



struct PlaceModel: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let description: String
}

struct RouteModel: Identifiable {
    let id = UUID()
    let title: String
    let duration: String
    let places: [String]
    let rating: Float
}

struct FeedItemModel: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let likes: Int
    let comments: Int
    let isBookmarked: Bool
}

struct PlaceCard: View {
    let place: PlaceModel
    
    var body: some View {
        VStack {
            Text(place.emoji)
                .font(.title)
            Text(place.name)
                .font(.headline)
                .fontWeight(.medium)
            Text(place.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 120)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct RouteCard: View {
    let route: RouteModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(route.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(route.duration)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", route.rating))
                        .font(.caption)
                }
            }
            
            Text("경유지: \(route.places.joined(separator: " → "))")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.vertical, 4)
            
            Button("상세보기") {
                // Route detail logic
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct FeedItemCard: View {
    let item: FeedItemModel
    
    var body: some View {
        VStack {
            // 이미지 영역
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 120)
                .overlay(
                    Text(item.emoji)
                        .font(.largeTitle)
                )
                .cornerRadius(8)
            
            // 내용 영역
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: item.isBookmarked ? "star.fill" : "star")
                        .foregroundColor(item.isBookmarked ? .yellow : .gray)
                        .font(.caption)
                }
                
                HStack {
                    HStack(spacing: 4) {
                        Text("🔥")
                        Text("\(item.likes)")
                    }
                    .font(.caption2)
                    
                    HStack(spacing: 4) {
                        Text("댓글")
                        Text("\(item.comments)")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Sample Data
let samplePlaces = [
    PlaceModel(name: "명동", emoji: "🛍️", description: "쇼핑의 메카"),
    PlaceModel(name: "성수", emoji: "☕", description: "카페 거리"),
    PlaceModel(name: "홍대", emoji: "🎵", description: "젊음의 거리"),
    PlaceModel(name: "강남", emoji: "🏢", description: "비즈니스 중심가"),
    PlaceModel(name: "이태원", emoji: "🌍", description: "다국적 문화"),
    PlaceModel(name: "용산", emoji: "🏛️", description: "역사와 현대")
]

let sampleRoutes = [
    RouteModel(title: "서울 고궁 투어", duration: "4시간", places: ["경복궁", "창덕궁", "덕수궁"], rating: 4.8),
    RouteModel(title: "한강 라이딩", duration: "2시간", places: ["뚝섬", "반포", "여의도"], rating: 4.6),
    RouteModel(title: "카페 투어", duration: "3시간", places: ["성수", "연남동", "합정"], rating: 4.7),
    RouteModel(title: "야경 명소", duration: "5시간", places: ["N서울타워", "반포대교", "세빛둥둥섬"], rating: 4.9)
]

let sampleFeedItems = [
    FeedItemModel(title: "서울 야경 투어 코스", emoji: "🌃", likes: 24, comments: 8, isBookmarked: false),
    FeedItemModel(title: "부산 해변 드라이브", emoji: "🏖️", likes: 18, comments: 5, isBookmarked: true),
    FeedItemModel(title: "제주도 맛집 탐방", emoji: "🍜", likes: 32, comments: 12, isBookmarked: false),
    FeedItemModel(title: "경주 역사 여행", emoji: "🏛️", likes: 15, comments: 3, isBookmarked: false),
    FeedItemModel(title: "강릉 카페 투어", emoji: "☕", likes: 28, comments: 9, isBookmarked: true),
    FeedItemModel(title: "인천 차이나타운", emoji: "🥟", likes: 21, comments: 6, isBookmarked: false)
]
