//
//  CompletionScope.swift
//  HiRoute
//
//  Created by Jupond on 12/12/25.
//

enum CompletionScope {
    case success       // 서버 + 로컬 완료
    case localOnly     // 로컬만 완료
    case failure(Error)
}
