//
//  HorizontalChipCell.swift
//  HiRoute
//
//  Created by Jupond on 11/12/25.
//
import SwiftUI

struct HorizontalChipCell: View {
    let item: HorizontalChipModel
    let selectedSubtypes: Set<String>
    let onTap: (String) -> Void

    private var isActive: Bool {
        !selectedSubtypes.isEmpty
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(item.text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isActive ? .white : .black)
                .lineLimit(1)

            Image(systemName: "chevron.down")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(isActive ? .white : .gray)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(isActive ? Color.black : Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(isActive ? 0 : 0.5), lineWidth: 1)
        )
        .fixedSize()
        .contentShape(Rectangle())
        .onTapGesture { onTap(item.id) }
    }
}
