//
//  HomePlaceSection.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import SwiftUI

struct ScheduleList : View {

    private var getList : [ScheduleModel]
    private var getNationalityType : NationalityType
    private var getIsEditMode : Bool
    private var getOnClickCell : (ScheduleModel) -> Void
    private var getOnClickDelete : (String) -> Void
    private var getOnMove : ((Int, Int) -> Void)?
    private var getOnLongPress : (() -> Void)?
    init(
        setList: [ScheduleModel],
        setNationalityType : NationalityType,
        setIsEditMode: Bool = false,
        setOnClickCell: @escaping (ScheduleModel) -> Void,
        setOnClickDelete: @escaping (String) -> Void = { _ in },
        setOnMove: ((Int, Int) -> Void)? = nil,
        setOnLongPress: (() -> Void)? = nil
    ) {
        self.getList = setList
        self.getNationalityType = setNationalityType
        self.getIsEditMode = setIsEditMode
        self.getOnClickCell = setOnClickCell
        self.getOnClickDelete = setOnClickDelete
        self.getOnMove = setOnMove
        self.getOnLongPress = setOnLongPress
    }

    private func handleOnMove(source: IndexSet, destination: Int) {
        guard let sourceIndex = source.first else { return }
        let adjustedDestination = sourceIndex < destination ? destination - 1 : destination
        getOnMove?(sourceIndex, adjustedDestination)
    }

    var body: some View {
        if getIsEditMode {
            // 편집 모드: List + .onMove (드래그 리오더)
            List {
                ForEach(getList, id: \.uid) { scheduleModel in
                    ScheduleCell(
                        setScheduleModel: scheduleModel,
                        setUserNationlity: getNationalityType,
                        setIsEditMode: getIsEditMode,
                        setOnClickCell: { clickedModel in
                            getOnClickCell(clickedModel)
                        },
                        setOnClickDelete: { scheduleUID in
                            getOnClickDelete(scheduleUID)
                        }
                    )
                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                    .listRowBackground(Color.clear)
                }
                .onMove(perform: handleOnMove)
            }
            .listStyle(PlainListStyle())
            .environment(\.editMode, .constant(.active))
        } else {
            // 일반 모드: ScrollView (기존 레이아웃 유지)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(getList, id: \.uid) { scheduleModel in
                        ScheduleCell(
                            setScheduleModel: scheduleModel,
                            setUserNationlity: getNationalityType,
                            setIsEditMode: getIsEditMode,
                            setOnClickCell: { clickedModel in
                                getOnClickCell(clickedModel)
                            },
                            setOnClickDelete: { scheduleUID in
                                getOnClickDelete(scheduleUID)
                            },
                            setOnLongPress: {
                                getOnLongPress?()
                            }
                        )
                    }
                }
                .padding(.horizontal, 10)
            }
        }
    }
}
