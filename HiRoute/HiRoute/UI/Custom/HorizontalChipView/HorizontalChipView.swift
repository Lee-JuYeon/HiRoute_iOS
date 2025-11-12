//
//  HorizontalChipView.swift
//  HiRoute
//
//  Created by Jupond on 11/12/25.
//
import SwiftUI
import SwiftUI

struct HorizontalChipView: View {
    private let getList: [HorizontalChipModel]
    private let getOnClick: (HorizontalChipModel) -> Void

    init(
        setList: [HorizontalChipModel],
        setOnClick: @escaping (HorizontalChipModel) -> Void
    ) {
        self.getList = setList
        self.getOnClick = setOnClick
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(getList, id: \.id) { chip in
                    HorizontalChipCell(
                        item: chip,
                        onTap: { selectedChip in
                            getOnClick(selectedChip)
                        }
                    )
                }
            }
            .padding(.horizontal, 10)
        }
        .padding(.top, 8)
    }
}

extension HorizontalChipView {
    
    static let sampleData: [HorizontalChipModel] = [
        HorizontalChipModel(id: "cafe", imageName: "cup.and.saucer.fill", color: .black, text: "카페"),
        HorizontalChipModel(id: "restaurant", imageName: "fork.knife", color: .orange, text: "맛집"),
        HorizontalChipModel(id: "park", imageName: "tree.fill", color: .green, text: "공원"),
        HorizontalChipModel(id: "shopping", imageName: "bag.fill", color: .blue, text: "쇼핑"),
        HorizontalChipModel(id: "hospital", imageName: "cross.fill", color: .red, text: "병원")
    ]
    
}
