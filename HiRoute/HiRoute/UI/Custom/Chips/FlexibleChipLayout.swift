//
//  FlexibleChipLayout.swift
//  HiRoute
//
//  Created by Jupond on 7/7/25.
//
import SwiftUI

struct FlexibleChipLayout: View {
    let items: [String]
    @Binding var selectedItems: Set<String>
    let chipCellRadius: CGFloat
    let spacing: CGFloat
    let onTap: (String) -> Void
    
    @State private var totalHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        return ZStack(alignment: .topLeading) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                
                ChipCellView(
                    text: item,
                    isSelected: selectedItems.contains(item),
                    chipCellRadius: chipCellRadius
                ) {
                    onTap(item)
                }
                .padding([.horizontal, .vertical], spacing / 2)
                .alignmentGuide(.leading, computeValue: { dimension in
                    if (abs(width - dimension.width) > geometry.size.width) {
                        width = 0
                        height -= dimension.height
                    }
                    let result = width
                    if index == items.count - 1 {
                        width = 0 // 마지막 아이템 후 초기화
                    } else {
                        width -= dimension.width
                    }
                    return result
                })
                .alignmentGuide(.top, computeValue: { dimension in
                    let result = height
                    if index == items.count - 1 {
                        height = 0 // 마지막 아이템 후 초기화
                    }
                    return result
                })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
