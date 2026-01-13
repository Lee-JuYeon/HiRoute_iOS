//
//  DdayCountView.swift
//  HiRoute
//
//  Created by Jupond on 12/18/25.
//

import SwiftUI

struct DateTextView: View {
    
    @Binding var date : Date
    let nationalityType : NationalityType
    let modeType : ModeType
    let onDateChanged: (() -> Void)

    
    @ViewBuilder
    private func dateView() -> some View {
        Text(date.toLocalizedDateString(region: nationalityType))
            .font(.system(size: 14))
            .foregroundColor(Color.getColour(.label_alternative))
    }
    
    // "선택안된상태"를 나타내는 특별한 날짜
    private static let unselectedDate = Date.distantPast
        
    
    @ViewBuilder
    private func guidView() -> some View {
        Text(date == Self.unselectedDate ? "클릭하여 날짜를 선택해주세요." : date.toLocalizedDateString(region: nationalityType))
            .font(.system(size: 14))
            .foregroundColor(Color.getColour(.label_strong))
    }
    
    @State private var isShowSheet : Bool = false
    
    var body: some View {
        HStack(alignment:VerticalAlignment.center, spacing: 6) {
            Image("icon_calendar")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundColor(Color.getColour(modeType == .READ ? .label_alternative : .label_strong))
            
            if modeType == .READ {
                dateView()
            }else{
                guidView()
            }
            
        }
        .onTapGesture {
            if modeType != .READ {
                isShowSheet.toggle()
            }
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .bottomSheet(isOpen: $isShowSheet) {
            VStack(alignment: HorizontalAlignment.center){
                Text("날짜 변경")
                
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: .date
                )
                .onChange(of: date) { _ in
                    onDateChanged() // 날짜 변경시 콜백 호출
                }
                .datePickerStyle(WheelDatePickerStyle())  // iOS 14 호환
                
            }
        }
        
    }
}
