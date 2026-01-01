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
    private var getOnClickCell : (ScheduleModel) -> Void
    init(
        setList: [ScheduleModel],
        setNationalityType : NationalityType,
        setOnClickCell: @escaping (ScheduleModel) -> Void,
    ) {
        self.getList = setList
        self.getNationalityType = setNationalityType
        self.getOnClickCell = setOnClickCell
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(getList, id: \.uid) { scheduleModel in
                    ScheduleCell(
                        setScheduleModel: scheduleModel,
                        setUserNationlity: getNationalityType) { clickedModel in
                            getOnClickCell(clickedModel)
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
}
