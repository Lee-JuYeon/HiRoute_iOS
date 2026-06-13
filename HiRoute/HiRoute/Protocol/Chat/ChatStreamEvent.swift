//
//  ChatStreamEvent.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//  [2026-06-07] AI 연동: .recommendation(코스데이터)·.session(상태) 추가.
//

enum ChatStreamEvent {
    /// 토큰 한 글자 emit
    case chunk(String)
    /// 응답에 첨부할 장소 카드들 (한 번 emit, finished 전)
    case attach(places: [PlaceModel])
    /// 추천 코스 구조화 데이터 (코스 전용 카드 렌더용; 있을 때만)
    case recommendation(AIRecommendation)
    /// 갱신된 대화 세션(프로필+히스토리) — 다음 턴/영속화용
    case session(AIChatSession)
    /// 스트림 종료
    case finished
}
