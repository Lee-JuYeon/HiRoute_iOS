//
//  PeriodResponse.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//

import SwiftUI

struct SheetTravelSpotView : View {
    
    let model: PlaceModel
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 헤더
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: model.iconName)
                            .foregroundColor(model.iconColor)
                            .font(.title2)
                        
                        Text(model.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    if let subtitle = model.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(getTypeDescription(model.type))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(model.iconColor.opacity(0.2))
                        .foregroundColor(model.iconColor)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button("닫기") {
                    onClose()
                }
                .foregroundColor(.blue)
            }
            
            Divider()
            
            // 상세 정보
           
            
            Divider()
            
            // 액션 버튼들
            HStack(spacing: 12) {
                Button(action: {
                    // 길찾기 기능
                    print("길찾기 클릭")
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("길찾기")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    // 즐겨찾기 기능
                    print("즐겨찾기 클릭")
                }) {
                    HStack {
                        Image(systemName: "heart")
                        Text("즐겨찾기")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(Color.white)
    }
    
    private func getTypeDescription(_ type: AnnotationType) -> String {
        switch type {
        case .hospital: return "병원"
        case .store: return "편의점"
        case .cafe: return "카페"
        case .restaurant: return "음식점"
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
            
            Spacer()
        }
    }
}
