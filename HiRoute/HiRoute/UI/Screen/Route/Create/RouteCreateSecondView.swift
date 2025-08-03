//
//  RouteCreateSecondView.swift
//  HiRoute
//
//  Created by Jupond on 7/6/25.
//
import SwiftUI

struct RouteCreateSecondView : View {
    
  
    @ViewBuilder
    private func title() -> some View {
        let marginBottom : CGFloat = 16
        let fontSize : CGFloat = 25
        Text("어떤 스타일의\n루트를 짜고 싶은신가요?")
            .font(.system(size: fontSize,weight: .bold))
            .foregroundColor(Color.getColour(.label_strong))
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                alignment: .topLeading
            )
            .padding(EdgeInsets(top: 0, leading: 0, bottom: marginBottom, trailing: 0))
    }

    @ViewBuilder
    private func titleChipsView(
        title: String,
        subTitle: String,
        selectedChips : Binding<Set<String>>,
        items : [String]
    ) -> some View {
        let marginTop : CGFloat = 24
        let spacingChipWithTitle : CGFloat = 12
        VStack(alignment: HorizontalAlignment.leading, spacing: spacingChipWithTitle){
            HStack(alignment: VerticalAlignment.center, spacing: 8){
                Text(title)
                    .font(.system(size: 16,weight: .bold))
                    .foregroundColor(Color.getColour(.label_strong))
                
                
                Text(subTitle)
                    .font(.system(size: 12,weight: .light))
                    .foregroundColor(Color.getColour(.label_alternative))
            }
            
            ChipView(
                items: items,
                selectedItems: selectedChips,
                chipCellRadius: 41
            )
        }
        .padding(EdgeInsets(top: marginTop, leading: 0, bottom: 0, trailing: 0))
        
    }
    
    @Binding var selectedIndex : Int
    @Binding var isShowRouteView : Bool
    private func skipNextButton() -> some View {
        Button {
            print("종료")
            isShowRouteView.toggle()
        } label: {
            let fontSize : CGFloat = 12
            let verticalInnerPadding : CGFloat = 12
            Text("선택하지 않고 건너 뛰기")
                .font(.system(size: fontSize,weight: .bold))
                .foregroundColor(Color.getColour(.label_alternative))
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
                .padding(.vertical, verticalInnerPadding)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func nextButton() -> some View {
        Button {
            print("종료")
            isShowRouteView.toggle()
        } label: {
            let fontSize : CGFloat = 16
            let verticalInnerPadding : CGFloat = 14
            let cornerRadius : CGFloat = 8
            Text("루트짜기")
                .font(.system(size: fontSize,weight: .bold))
                .foregroundColor(Color.getColour(.background_white))
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
                .padding(.vertical, verticalInnerPadding)
                .background(Color.getColour(.label_strong))
                .cornerRadius(cornerRadius)
        }
        .buttonStyle(PlainButtonStyle())


    }
    
    @State private var selectedPeopleChips: Set<String> = []
    private let peopleList = ["혼자", "친구(들)과", "연인과", "가족과", "동료와", "기타"]
   
    @State private var selectedActivityChips: Set<String> = []
    private let activityList = ["맛집 탐방", "카페 투어", "데이트", "특별한 기념일", "산책/힐링", "문화/전시", "쇼핑"]
    
    @State private var selectedTimeChips: Set<String> = []
    private let timeList = ["오전", "오후", "하루 종일"]
    
    var body: some View {
        VStack(spacing:0){
            title()
            
            titleChipsView(
                title: "누구와 함께 하시나요?",
                subTitle: "",
                selectedChips: $selectedPeopleChips,
                items: peopleList
            )
            
            titleChipsView(
                title: "어떤 활동을 하고 싶으신가요?",
                subTitle: "(중복선택 가능)",
                selectedChips: $selectedActivityChips,
                items: activityList
            )
            
            titleChipsView(
                title: "약속 시간대는 언제인가요?",
                subTitle: "(중복선택 가능)",
                selectedChips: $selectedTimeChips,
                items: timeList
            )
            
            Spacer()
            
            nextButton()
            skipNextButton()
        }
        .background(Color.getColour(.background_yellow_white))
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

