//
//  ModeType.swift
//  HiRoute
//
//  Created by Jupond on 11/25/25.
//

/*
 ModeType.READ = 스케줄 읽기
 ModeType.EDIT = 스케줄 편집
 ModeType.ADD = 스케줄 작성
 */

enum ModeType : String, Codable, CaseIterable {
    case READ = "READ"
    case CREATE = "CREATE"
    case UPDATE = "UPDATE"
    
    var displayText: String {
        return self.rawValue
    }
}


