//
//  ScheduleReorderRequest.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

struct ScheduleReorderRequest: Encodable {
    let orders: [ReorderItem]
}
