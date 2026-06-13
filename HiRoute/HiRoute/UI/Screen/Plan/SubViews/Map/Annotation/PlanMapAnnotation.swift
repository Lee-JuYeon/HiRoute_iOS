//
//  StoreCell.swift
//  HiRoute
//
//  Created by Jupond on 8/3/25.
//
import SwiftUI

struct PlanMapAnnotation : View {
    let visitPlaceModel: PlanModel
    @EnvironmentObject private var scheduleVM: ScheduleVM
    @EnvironmentObject private var navigationVM: NavigationVM

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(spacing: 0) {
                    Circle()
                        .fill(Color.getColour(.label_strong))
                        .frame(width: 30, height: 30)
                        .customElevation(.normal)

                    Triangle()
                        .fill(Color.getColour(.label_strong))
                        .frame(width: 8, height: 6)
                        .offset(y: -1)
                }

                Text("\(visitPlaceModel.index)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.getColour(.background_white))
                    .offset(y: -3)
            }

            Text(visitPlaceModel.placeModel.title)
                .font(.caption2)
                .foregroundColor(Color.getColour(.label_strong))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.getColour(.background_white).opacity(0.9))
                .cornerRadius(4)
                .padding(.top, 2)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            scheduleVM.planEvent.selectPlan(visitPlaceModel)
            navigationVM.navigateTo(setDestination: .place)
        }
    }
}
