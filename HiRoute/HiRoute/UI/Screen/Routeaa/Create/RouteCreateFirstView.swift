//
//  RouteCreateFirstView.swift
//  HiRoute
//
//  Created by Jupond on 7/6/25.
//
import SwiftUI

struct RouteCreateFirstView : View {
    
    
    
    @State private var routeNameText = ""
    @ViewBuilder
    private func routeName() -> some View {
        let verticalSpacing : CGFloat = 8
        let radius : CGFloat = 8
        let innerPadding : CGFloat = 12
        VStack(alignment: .leading, spacing: verticalSpacing) {
            Text("루트 이름")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_strong))
                .fontWeight(.none)
                
            TextField("생성할 루트 이름을 입력해 주세요.(최대 20자)", text: $routeNameText)

                .padding(innerPadding)
                .background(Color.getColour(.background_white))

                .lineLimit(1)
                .font(.system(size: 14))
                .cornerRadius(radius)
                .keyboardType(.default)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .customElevation(.normal)
                .onChange(of: routeNameText) { newValue in
                    if newValue.count > 20 {
                        routeNameText = String(newValue.prefix(20))
                    }
                }
              
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(EdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0))
    }
    
    @State private var dateText = ""
    @State private var isShowDateSheet = false
    
    @State private var placeText = ""
    @State private var isShowPlaceSheet = false
    
    @ViewBuilder
    private func pickableTextField(title: String, hint: String, bindingText: Binding<String>, icon: String, isShowSheet: Binding<Bool>) -> some View {
        
        let fontSize : CGFloat = 14
        let titleTextFieldSpacing : CGFloat = 8
        let radius : CGFloat = 8
        let textfieldPadding : CGFloat = 12
        let topMargin : CGFloat = 24
        VStack(alignment: .leading, spacing: titleTextFieldSpacing) {
            Text(title)
                .font(.system(size: fontSize))
                .foregroundColor(Color.getColour(.label_strong))
                .fontWeight(.none)
                
            Button {
                isShowSheet.wrappedValue = true
            } label: {
                HStack(alignment: .center) {
                    if bindingText.wrappedValue.isEmpty {
                        Text(hint)
                            .font(.system(size: fontSize))
                            .foregroundColor(Color.getColour(.label_assistive))
                    } else {
                        Text(bindingText.wrappedValue)
                            .font(.system(size: fontSize))
                            .foregroundColor(Color.getColour(.label_strong))
                    }
                    
                    Spacer()
                    
                    Image(icon)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.getColour(.label_alternative))
                }
                .padding(EdgeInsets(top: textfieldPadding, leading: textfieldPadding, bottom: textfieldPadding, trailing: textfieldPadding))
            }
            .background(Color.getColour(.background_white))
            .cornerRadius(radius)
            .customElevation(.normal)

        }
        .padding(EdgeInsets(top: topMargin, leading: 0, bottom: 0, trailing: 0))
    }
    
    @Binding var selectedIndex : Int
    @ViewBuilder
    private func nextButton() -> some View {
        let cornerRadius: CGFloat = 8
        let fontSize: CGFloat = 16
        let buttonInnerVerticalPadding: CGFloat = 14
        
        Button(action: {
            if (dateText.count != 0 && placeText.count != 0 && routeNameText.count != 0) {
                selectedIndex = selectedIndex + 1
            }
        }, label: {
            Text("다음")
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(
                    (dateText.count != 0 && placeText.count != 0 && routeNameText.count != 0)
                    ? Color.getColour(.background_white)
                    : Color.getColour(.label_assistive)
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(EdgeInsets(
                    top: buttonInnerVerticalPadding,
                    leading: buttonInnerVerticalPadding,
                    bottom: buttonInnerVerticalPadding,
                    trailing: buttonInnerVerticalPadding
                ))
        })
        .frame(height: 48)
        .background(
            (dateText.count != 0 && placeText.count != 0 && routeNameText.count != 0)
            ? Color.getColour(.label_strong)
            : Color.getColour(.label_disable)
        )
        .cornerRadius(cornerRadius)
    }
    
    
    
   
    var body: some View {
        VStack(){
            Text("생성할 루트의 정보를\n입력해 주세요")
                .font(.system(size: 24))
                .foregroundColor(Color.getColour(.label_strong))
                .fontWeight(.bold)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            
            routeName()
            
            pickableTextField(
                title: "약속 날짜",
                hint: "약속 날짜를 선택해 주세요",
                bindingText: $dateText,
                icon: "icon_calendar",
                isShowSheet: $isShowDateSheet
            )
            
            pickableTextField(
                title: "약속 장소",
                hint: "약속 장소를 선택해 주세요",
                bindingText: $placeText,
                icon: "icon_pin",
                isShowSheet: $isShowPlaceSheet
            )
            
            Spacer()
            
            nextButton()
            
            Spacer()
        }
        .bottomSheet(isOpen: $isShowDateSheet, setContent: {
            SheetCalendarView()
        })
        .bottomSheet(isOpen: $isShowPlaceSheet, setContent: {
            SheetPlaceChoiceView()
        })
        .background(Color.getColour(.background_yellow_white))
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}




