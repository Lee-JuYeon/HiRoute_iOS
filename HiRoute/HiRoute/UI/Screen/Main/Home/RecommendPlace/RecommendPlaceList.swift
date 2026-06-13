//
//  HomePlaceCell 2.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import SwiftUI

struct RecommendPlaceList : View {

    private var getList : [PlaceModel]
    private var getBookmarkedIds : Set<String>
    private var getOnClickCell : (PlaceModel) -> Void
    private var getOnClickBookMark : (String) -> Void
    init(
        setList : [PlaceModel],
        setBookmarkedIds : Set<String>,
        setOnClickCell : @escaping (PlaceModel) -> Void,
        setOnClickBookMark : @escaping (String) -> Void
    ){
        self.getList = setList
        self.getBookmarkedIds = setBookmarkedIds
        self.getOnClickCell = setOnClickCell
        self.getOnClickBookMark = setOnClickBookMark
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(getList, id: \.uid) { model in
                    RecommendPlaceCell(
                        model: model,
                        isBookmarked: getBookmarkedIds.contains(model.uid),
                        onCellClickEvent: { model in
                            getOnClickCell(model)
                        },
                        onBookMarkClickEvent: { id in
                            getOnClickBookMark(id)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
