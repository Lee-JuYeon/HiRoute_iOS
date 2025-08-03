//
//  HomePlaceCell 2.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import SwiftUI

struct TrendPlaceList : View {
    
    private var getList : [RouteModel]
    private var getOnClickCell : (RouteModel) -> Void
    private var getOnClickBookMark : (String) -> Void
    init(
        setList : [RouteModel],
        setOnClickCell : @escaping (RouteModel) -> Void,
        setOnClickBookMark : @escaping (String) -> Void
    ){
        self.getList = setList
        self.getOnClickCell = setOnClickCell
        self.getOnClickBookMark = setOnClickBookMark
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(getList, id: \.routeUID) { model in
                    RecyclableRouteCell(
                        model: model,
                        type: RouteCellType.trendingRoute,
                        onCellClickEvent: { routeModel in
                            print("지금 인기 있는 장소 카드 클릭 : \(routeModel.routeTitle)")
                            getOnClickCell(routeModel)
                        },
                        onBookMarkClickEvent: { routeUID in
                            print("지금 인기 있는 장소 북마크 클릭: \(routeUID)")
                            getOnClickBookMark(routeUID)
                            return true // 새로운 북마크 상태 반환
                        }
                        
                    )
                }
            }
        }
    }
}
