//
//  FeedRepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import Foundation
import Combine

/**
 * VisitPlaceProtocol
 * - VisitPlace 도메인의 데이터 액세스 인터페이스
 * - Repository 패턴으로 구체적인 구현체를 추상화
 * - Schedule과 Place를 연결하는 중간 엔티티 관리
 */
protocol PlanProtocol {
    /**
     * 새 방문장소 생성
     * - Schedule에 Place를 추가할 때 사용
     * - index는 Schedule 내에서의 순서를 의미
     * @param visitPlace: 생성할 방문장소 모델
     * @return: 생성된 방문장소 Publisher
     */
    func createPlan(_ planModel: PlanModel, scheduleUID : String) -> AnyPublisher<PlanModel, Error>
    
    /**
     * 특정 방문장소 조회
     * - UID로 단일 방문장소 조회
     * - Place 정보와 File 정보도 함께 로드
     * @param uid: 조회할 방문장소의 고유 식별자
     * @return: 조회된 방문장소 Publisher
     */
    func readPlan(planUID: String) -> AnyPublisher<PlanModel, Error>
    
    /**
     * 특정 일정의 모든 방문장소 조회
     * - Schedule에 속한 VisitPlace들을 index 순서로 정렬하여 반환
     * - 일정 상세보기에서 방문장소 목록 표시할 때 사용
     * @param scheduleUID: 일정의 고유 식별자
     * @return: 정렬된 방문장소 목록 Publisher
     */
    func readPlanList(scheduleUID: String) -> AnyPublisher<[PlanModel], Error>
    
    /**
     * 방문장소 정보 수정
     * - memo, index 등 VisitPlace 속성 수정
     * - Place 정보 변경은 PlaceService에서 처리
     * @param visitPlace: 수정된 방문장소 모델
     * @return: 수정된 방문장소 Publisher
     */
    func updatePlan(_ planModel: PlanModel) -> AnyPublisher<PlanModel, Error>
    
    /**
     * 방문장소 삭제
     * - Schedule에서 Place 제거할 때 사용
     * - 연결된 File들도 Cascade 삭제됨
     * @param uid: 삭제할 방문장소의 고유 식별자
     * @return: 삭제 완료 Publisher
     */
    func deletePlan(planUID: String) -> AnyPublisher<Void, Error>  // ✅ planUID 유지

 
    func updatePlanMemo(planUID: String, memo: String) -> AnyPublisher<PlanModel, Error>
    func updatePlanIndex(planUID: String, newIndex: Int) -> AnyPublisher<PlanModel, Error>

    /**
     * 다중 방문장소 순서 재정렬
     * - 사용 예시: 사용자가 드래그앤드롭으로 "카페A → 박물관 → 카페B" 순서를 "박물관 → 카페A → 카페B"로 변경
     * - planUIDs: 새로운 순서대로 정렬된 Plan UID 배열 ["museum123", "cafe456", "cafe789"]
     * - 각 Plan의 index가 배열 순서에 맞게 0, 1, 2로 자동 업데이트됨
     */
    func reorderPlans(planUIDs: [String]) -> AnyPublisher<[PlanModel], Error>
}
