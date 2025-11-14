//
//  HomePlaceSection.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import SwiftUI
//
//struct LocalisedPlaceSection : View {
//    
//    private var getTitle : String
//    private var getOnClickTotal : () -> Void
//    private var getList : [RouteModel]
//    private var getOnClickCell : (RouteModel) -> Void
//    private var getOnClickBookMark : (String) -> Void
//    init(
//        getTitle: String,
//        getOnClickTotal: @escaping () -> Void,
//        getList: [RouteModel],
//        getOnClickCell: @escaping (RouteModel) -> Void,
//        getOnClickBookMark: @escaping (String) -> Void
//    ) {
//        self.getTitle = getTitle
//        self.getOnClickTotal = getOnClickTotal
//        self.getList = getList
//        self.getOnClickCell = getOnClickCell
//        self.getOnClickBookMark = getOnClickBookMark
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            LocalisedPlaceTitleView(
//                setTitle: getTitle,
//                setOnClickTotalView: {
//                    getOnClickTotal()
//                }
//            )
//            
//            LocalisedPlaceChips()
//
//            
//            LocalisedPlaceList(
//                setList: getList,
//                setOnClickCell: { model in
//                    getOnClickCell(model)
//                },
//                setOnClickBookMark: { routeUID in
//                    getOnClickBookMark(routeUID)
//                }
//            )
//            
//            
//            
//        }
//        .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
//    }
//}
