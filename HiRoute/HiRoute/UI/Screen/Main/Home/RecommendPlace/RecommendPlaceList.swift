//
//  HomePlaceCell 2.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import SwiftUI

struct RecommendPlaceList : View {
    
    private var getList : [PlaceModel]
    private var getOnClickCell : (PlaceModel) -> Void
    private var getOnClickBookMark : (String) -> Void
    init(
        setList : [PlaceModel],
        setOnClickCell : @escaping (PlaceModel) -> Void,
        setOnClickBookMark : @escaping (String) -> Void
    ){
        self.getList = setList
        self.getOnClickCell = setOnClickCell
        self.getOnClickBookMark = setOnClickBookMark
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(getList, id: \.uid) { model in
                    RecommendPlaceCell(
                        model: model,
                        onCellClickEvent: { model in
                            getOnClickCell(model)
                        },
                        onBookMarkClickEvent: { id in
                            getOnClickBookMark(id)
                            return true // 새로운 북마크 상태 반환
                        }
                        
                    )
                }
            }
            .padding(.horizontal, 16) 
        }
    }
}
