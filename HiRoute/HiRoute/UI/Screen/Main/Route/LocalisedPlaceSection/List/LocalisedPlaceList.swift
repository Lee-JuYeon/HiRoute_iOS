//
//  HomePlaceListView.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import SwiftUI

//struct LocalisedPlaceList : View {
//    
//    private var list : [RouteModel]
//    private var onClickCell : (RouteModel) -> Void
//    private var onClickBookMark : (String) -> Void
//    init(
//        setList : [RouteModel],
//        setOnClickCell : @escaping (RouteModel) -> Void,
//        setOnClickBookMark : @escaping (String) -> Void
//    ){
//        self.list = setList
//        self.onClickCell = setOnClickCell
//        self.onClickBookMark = setOnClickBookMark
//    }
//    
//    @ViewBuilder
//    private func placeList() -> some View {
//        let horizontalCellSpacing : CGFloat = 16
//        let verticalCellSpacing : CGFloat = 16
//        LazyVGrid(
//            columns: Array(repeating: GridItem(.flexible(), spacing: horizontalCellSpacing), count: 2), // 좌우간견 16
//            spacing: verticalCellSpacing,  // 상하 간격
//            content: {
//                ForEach(list, id: \.routeUID) { model in
//                    RecyclableRouteCell(
//                        model: model,
//                        type: RouteCellType.localisedRoute,
//                        onCellClickEvent: { routeModel in
//                            print("지역 맞춤 장소 카드 클릭 : \(routeModel.routeTitle)")
//                            onClickCell(routeModel)
//                        },
//                        onBookMarkClickEvent: { routeUID in
//                            print("지역 맞춤 장소 북마크 클릭: \(routeUID)")
//                            onClickBookMark(routeUID)
//                            return true
//                        }
//                    )
//                }
//            }
//        )
//    }
//    
//    var body: some View {
//        placeList()
//    }
//}
