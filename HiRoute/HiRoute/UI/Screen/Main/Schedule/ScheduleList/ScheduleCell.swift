//
//  HomePlaceChips.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import SwiftUI

struct ScheduleCell : View {

    private var getScheduleModel : ScheduleModel
    private var getUserNationality : NationalityType
    private var getIsEditMode : Bool
    private var onClickCell : (ScheduleModel) -> Void
    private var onClickDelete : (String) -> Void
    private var onLongPress : (() -> Void)?
    init(
        setScheduleModel: ScheduleModel,
        setUserNationlity: NationalityType,
        setIsEditMode: Bool = false,
        setOnClickCell : @escaping (ScheduleModel) -> Void,
        setOnClickDelete : @escaping (String) -> Void = { _ in },
        setOnLongPress : (() -> Void)? = nil
    ) {
        self.getScheduleModel = setScheduleModel
        self.onClickCell = setOnClickCell
        self.getUserNationality = setUserNationlity
        self.getIsEditMode = setIsEditMode
        self.onClickDelete = setOnClickDelete
        self.onLongPress = setOnLongPress
    }

    @ViewBuilder
    private func view(model : ScheduleModel) -> some View {
        let verticalSpacing : CGFloat = 12
        let horizontalSpacing : CGFloat = 8
        HStack(spacing: 0) {
            if getIsEditMode {
                ZStack {
                    Circle()
                        .fill(Color.getColour(.label_strong))
                        .frame(width: 28, height: 28)
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.getColour(.background_white))
                }
                .padding(.trailing, 8)
                .onTapGesture {
                    onClickDelete(model.uid)
                }
            }

            VStack(alignment:HorizontalAlignment.leading, spacing: verticalSpacing){
                Text(model.title)
                    .font(.system(size: 16))
                    .foregroundColor(Color.getColour(.label_strong))
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)

                Text(model.memo)
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_neutral))
                    .lineLimit(3)

                Text(model.d_day.toLocalizedDateString(region: getUserNationality))
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(12)
        .frame(
            maxWidth: .infinity,
            alignment: Alignment.leading
        )
        .background(Color.getColour(.background_white))
        .cornerRadius(12)
        .customElevation(.normal)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.getColour(.label_alternative), lineWidth: 1)
        )
        .onTapGesture {
            onClickCell(model)
        }
        .onLongPressGesture {
            onLongPress?()
        }
    }

    var body: some View {
        view(model: getScheduleModel)
    }
}
