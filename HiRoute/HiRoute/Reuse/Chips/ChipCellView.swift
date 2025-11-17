//
//  ChipView.swift
//  HiRoute
//
//  Created by Jupond on 7/7/25.
//
import SwiftUI

struct ChipCellView: View {
    let text: String
    let isSelected: Bool
    let chipCellRadius: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        let horizontalInnerSpacing: CGFloat = 12
        let verticalInnerSpacing: CGFloat = 8
        
        Button(action: onTap) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? Color.white : Color.black)
                .lineLimit(1)
        }
        .padding(EdgeInsets(
            top: verticalInnerSpacing,
            leading: horizontalInnerSpacing,
            bottom: verticalInnerSpacing,
            trailing: horizontalInnerSpacing
        ))
        .background(isSelected ? Color.black : Color.white)
        .cornerRadius(chipCellRadius)
        .customElevation(.normal)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

//
//// 더 간단한 대안 - 행 단위로 나누어 배치
//struct SimpleFlexibleChipLayout: View {
//    let items: [String]
//    @Binding var selectedItems: Set<String>
//    let chipCellRadius: CGFloat
//    let spacing: CGFloat
//    let onTap: (String) -> Void
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: spacing) {
//            ForEach(createRows(), id: \.self) { row in
//                HStack(spacing: spacing) {
//                    ForEach(row, id: \.self) { item in
//                        ChipCellView(
//                            text: item,
//                            isSelected: selectedItems.contains(item),
//                            chipCellRadius: chipCellRadius
//                        ) {
//                            onTap(item)
//                        }
//                    }
//                    Spacer()
//                }
//            }
//        }
//    }
//    
//    private func createRows() -> [[String]] {
//        var rows: [[String]] = []
//        var currentRow: [String] = []
//        var currentRowWidth: CGFloat = 0
//        let maxWidth: CGFloat = UIScreen.main.bounds.width - 32 // 좌우 패딩 고려
//        
//        for item in items {
//            let estimatedWidth = estimateTextWidth(item)
//            
//            if currentRowWidth + estimatedWidth + spacing <= maxWidth {
//                currentRow.append(item)
//                currentRowWidth += estimatedWidth + spacing
//            } else {
//                if !currentRow.isEmpty {
//                    rows.append(currentRow)
//                }
//                currentRow = [item]
//                currentRowWidth = estimatedWidth
//            }
//        }
//        
//        if !currentRow.isEmpty {
//            rows.append(currentRow)
//        }
//        
//        return rows
//    }
//    
//    private func estimateTextWidth(_ text: String) -> CGFloat {
//        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        let attributes = [NSAttributedString.Key.font: font]
//        let size = (text as NSString).size(withAttributes: attributes)
//        return size.width + 24 // 패딩 12 * 2
//    }
//}
