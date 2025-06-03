//
//  HomeView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct HomeView: View {
    let onNavigateToScheduleCreate: () -> Void
    let onNavigateToScheduleGacha: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 상단 버튼들
                HStack(spacing: 10) {
                    Button(action: onNavigateToScheduleCreate) {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                            Text("일정 만들기")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Button(action: onNavigateToScheduleGacha) {
                        VStack {
                            Image(systemName: "calendar.circle.fill")
                                .font(.title)
                                .foregroundColor(.green)
                            Text("일정 뽑기")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)  // <- 여기에 이 줄 추가

                
                // 인기 장소 섹션
                VStack(
                    alignment: .leading
                ) {
                    HStack {
                        Text("지금 인기있는 장소")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(samplePlaces, id: \.id) { place in
                                PlaceCard(place: place)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
                
                // 인기 루트 섹션
                VStack(alignment: .leading) {
                    HStack {
                        Text("인기 루트")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(sampleRoutes, id: \.id) { route in
                            RouteCard(route: route)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))

            }

        }

    }
    
}

