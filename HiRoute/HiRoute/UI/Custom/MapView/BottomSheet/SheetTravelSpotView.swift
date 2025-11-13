//
//  PeriodResponse.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//

import SwiftUI

struct SheetTravelSpotView : View {
    
    let model: AnnotationModel
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
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(title: "위치", value: "\(String(format: "%.4f", model.coordinate.latitude)), \(String(format: "%.4f", model.coordinate.longitude))")
                
                InfoRow(title: "카테고리", value: getTypeDescription(model.type))
                
                if model.type == .hospital {
                    InfoRow(title: "진료시간", value: "09:00 - 18:00")
                    InfoRow(title: "응급실", value: "24시간 운영")
                } else if model.type == .store {
                    InfoRow(title: "운영시간", value: "24시간")
                    InfoRow(title: "결제방법", value: "현금, 카드, 페이 가능")
                } else if model.type == .cafe {
                    InfoRow(title: "운영시간", value: "07:00 - 22:00")
                    InfoRow(title: "특징", value: "WiFi, 콘센트 제공")
                } else if model.type == .restaurant {
                    InfoRow(title: "운영시간", value: "11:00 - 21:00")
                    InfoRow(title: "주요메뉴", value: "한식, 양식")
                }
            }
            
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
