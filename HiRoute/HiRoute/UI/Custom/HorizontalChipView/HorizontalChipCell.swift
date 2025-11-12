//
//  HorizontalChipView.swift
//  HiRoute
//
//  Created by Jupond on 11/12/25.
//
import SwiftUI

struct HorizontalChipCell: View {
    let item: HorizontalChipModel
    let onTap: (HorizontalChipModel) -> Void
    
    var body: some View {
        Button {
            onTap(item)
        } label: {
            HStack(spacing: 6) {
                // 왼쪽 아이콘
                Image(systemName: item.imageName)
                    .foregroundColor(item.color)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 16, height: 16, alignment: .center)
                
                // 오른쪽 텍스트
                Text(item.text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 1.5, x: 0, y: 1)
            .contentShape(Rectangle()) // 터치 범위 향상
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: item.id) // 클릭 반응 부드럽게
    }
}
