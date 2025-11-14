//
//  HotPlaceSection.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//
import SwiftUI

//struct TrendPlaceSection : View {
//    
//    private var getTitle : String
//    private var getList : [RouteModel]
//    private var getOnClickCell : (RouteModel) -> Void
//    private var getOnClickBookMark : (String) -> Void
//    init(
//        setTitle : String,
//        setList : [RouteModel],
//        setOnClickCell : @escaping (RouteModel) -> Void,
//        setOnClickBookMark : @escaping (String) -> Void
//    ){
//        self.getTitle = setTitle
//        self.getList = setList
//        self.getOnClickCell = setOnClickCell
//        self.getOnClickBookMark = setOnClickBookMark
//    }
//    
//    @ViewBuilder
//    private func title() -> some View {
//        Text(getTitle)
//            .font(.system(size: 16))
//            .fontWeight(Font.Weight.bold)
//            .foregroundColor(Color.getColour(.label_strong))
//    }
//    
//    var body: some View {
//        // 인기 장소 섹션
//        VStack(
//            alignment: .leading,
//            spacing: 16
//        ) {
//            title()
//            
//            TrendPlaceList(
//                setList: getList,
//                setOnClickCell: { model in
//                    getOnClickCell(model)
//                },
//                setOnClickBookMark: { routeUID in
//                    getOnClickBookMark(routeUID)
//                }
//            )
//        }
//        .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
//        
//    }
//}
