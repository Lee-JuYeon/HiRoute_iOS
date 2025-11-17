//
//  ChipsView.swift
//  HiRoute
//
//  Created by Jupond on 7/7/25.
//
import SwiftUI

struct ChipView: View {
    let items: [String]
    @Binding var selectedItems: Set<String>
    let chipCellRadius: CGFloat
    
    init(
        items: [String],
        selectedItems: Binding<Set<String>>,
        chipCellRadius: CGFloat
    ) {
        self.items = items
        self._selectedItems = selectedItems
        self.chipCellRadius = chipCellRadius
    }
    
    private func toggleSelection(for item: String) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }
    
    var body: some View {
        FlexibleChipLayout(
            items: items,
            selectedItems: $selectedItems,
            chipCellRadius: chipCellRadius,
            spacing: 8
        ) { item in
            toggleSelection(for: item)
        }
    }
}
