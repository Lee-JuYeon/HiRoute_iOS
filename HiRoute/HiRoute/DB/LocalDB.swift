//
//  Untitled.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//
import CoreData

class LocalDB {
    static let shared = LocalDB()
    private let backgroundContext: NSManagedObjectContext
    
    private init() {
        backgroundContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.undoManager = nil
        backgroundContext.shouldDeleteInaccessibleFaults = true
        print("LocalDB, init // Success : 백그라운드 컨텍스트 초기화 완료")
    }
        
    /// 일정 생성
    func createSchedule(_ schedule: ScheduleModel, completion: @escaping (Bool) -> Void) {
        print("LocalDB, createSchedule // Info : 일정 생성 시작 - \(schedule.uid)")
        ScheduleDAO.create(schedule, context: backgroundContext, completion: completion)
    }
    
    /// 일정 조회
    func readSchedule(scheduleUID: String, completion: @escaping (ScheduleModel?) -> Void) {
        print("LocalDB, readSchedule // Info : 일정 조회 시작 - \(scheduleUID)")
        ScheduleDAO.read(scheduleUID: scheduleUID, context: backgroundContext, completion: completion)
    }
    
    /// 모든 일정 조회
    func readAllSchedules(completion: @escaping ([ScheduleModel]) -> Void) {
        print("LocalDB, readAllSchedules // Info : 모든 일정 조회 시작")
        ScheduleDAO.readAll(context: backgroundContext, completion: completion)
    }
    
    /// 일정 업데이트
    func updateSchedule(_ schedule: ScheduleModel, completion: @escaping (Bool) -> Void) {
        print("LocalDB, updateSchedule // Info : 일정 업데이트 시작 - \(schedule.uid)")
        ScheduleDAO.update(schedule, context: backgroundContext, completion: completion)
    }
    
    /// [2026-05-26 Phase 2] 메타 필드만 업데이트 — chatHistory wipe 방지.
    func updateScheduleMeta(scheduleUID: String, title: String, memo: String, dDay: Date, editDate: Date, completion: @escaping (Bool) -> Void) {
        print("LocalDB, updateScheduleMeta // Info : 메타 업데이트 시작 - \(scheduleUID)")
        ScheduleDAO.updateMeta(scheduleUID: scheduleUID, title: title, memo: memo, dDay: dDay, editDate: editDate, context: backgroundContext, completion: completion)
    }

    /// 일정 인덱스 업데이트
    func updateScheduleIndex(scheduleUID: String, newIndex: Int, completion: @escaping (Bool) -> Void) {
        print("LocalDB, updateScheduleIndex // Info : Schedule 인덱스 업데이트 시작 - \(scheduleUID)")
        ScheduleDAO.updateIndex(scheduleUID: scheduleUID, newIndex: newIndex, context: backgroundContext, completion: completion)
    }

    /// [2026-05-26 Phase 3] 복구 가능 항목 조회 (soft-deleted).
    func loadDeletedItems(completion: @escaping ([ScheduleDAO.DeletedItem]) -> Void) {
        ScheduleDAO.loadDeletedItems(context: backgroundContext, completion: completion)
    }

    /// [2026-05-26 Phase 3] 항목 복구 (deletedAt = nil).
    func restoreDeletedItem(_ item: ScheduleDAO.DeletedItem, completion: @escaping (Bool) -> Void) {
        ScheduleDAO.restore(item: item, context: backgroundContext, completion: completion)
    }

    /// 일정 삭제
    func deleteSchedule(scheduleUID: String, completion: @escaping (Bool) -> Void) {
        print("LocalDB, deleteSchedule // Info : 일정 삭제 시작 - \(scheduleUID)")
        ScheduleDAO.delete(scheduleUID: scheduleUID, context: backgroundContext, completion: completion)
    }

    /// 일정에 채팅 메시지 한 건 추가
    func appendChatMessageToSchedule(scheduleUID: String, message: ChatMessageModel, completion: @escaping (Bool) -> Void) {
        ScheduleDAO.appendChatMessage(scheduleUID: scheduleUID, message: message, context: backgroundContext, completion: completion)
    }
    
    
    /// Plan 생성
    func createPlan(_ plan: PlanModel, scheduleUID: String, completion: @escaping (Bool) -> Void) {
        print("LocalDB, createPlan // Info : Plan 생성 시작 - \(plan.uid)")
        PlanDAO.create(plan, scheduleUID: scheduleUID, context: backgroundContext, completion: completion)
    }
    
    /// Plan 조회
    func readPlan(planUID: String, completion: @escaping (PlanModel?) -> Void) {
        print("LocalDB, readPlan // Info : Plan 조회 시작 - \(planUID)")
        PlanDAO.read(planUID: planUID, context: backgroundContext, completion: completion)
    }
    
    /// Plan 목록 조회
    func readPlanList(scheduleUID: String, completion: @escaping ([PlanModel]) -> Void) {
        print("LocalDB, readPlanList // Info : Plan 목록 조회 시작 - \(scheduleUID)")
        PlanDAO.readAll(scheduleUID: scheduleUID, context: backgroundContext, completion: completion)
    }
    
    /// Plan 업데이트
    func updatePlan(_ plan: PlanModel, completion: @escaping (Bool) -> Void) {
        print("LocalDB, updatePlan // Info : Plan 업데이트 시작 - \(plan.uid)")
        PlanDAO.update(plan, context: backgroundContext, completion: completion)
    }
    
    /// Plan 메모 업데이트
    func updatePlanMemo(planUID: String, memo: String, completion: @escaping (Bool) -> Void) {
        print("LocalDB, updatePlanMemo // Info : Plan 메모 업데이트 시작 - \(planUID)")
        PlanDAO.updateMemo(planUID: planUID, memo: memo, context: backgroundContext, completion: completion)
    }
    
    /// Plan 인덱스 업데이트
    func updatePlanIndex(planUID: String, newIndex: Int, completion: @escaping (Bool) -> Void) {
        print("LocalDB, updatePlanIndex // Info : Plan 인덱스 업데이트 시작 - \(planUID)")
        PlanDAO.updateIndex(planUID: planUID, newIndex: newIndex, context: backgroundContext, completion: completion)
    }
    
    /// Plan 삭제
    func deletePlan(planUID: String, completion: @escaping (Bool) -> Void) {
        print("LocalDB, deletePlan // Info : Plan 삭제 시작 - \(planUID)")
        PlanDAO.delete(planUID: planUID, context: backgroundContext, completion: completion)
    }

    // MARK: - User CRUD

    /// User 생성
    func createUser(_ user: UserModel, completion: @escaping (Bool) -> Void) {
        UserDAO.create(user, context: backgroundContext, completion: completion)
    }

    /// User 조회
    func readUser(uid: String, completion: @escaping (UserModel?) -> Void) {
        UserDAO.read(uid: uid, context: backgroundContext, completion: completion)
    }

    /// User 업데이트
    func updateUser(_ user: UserModel, completion: @escaping (Bool) -> Void) {
        UserDAO.update(user, context: backgroundContext, completion: completion)
    }

    /// User 삭제
    func deleteUser(uid: String, completion: @escaping (Bool) -> Void) {
        UserDAO.delete(uid: uid, context: backgroundContext, completion: completion)
    }

    // MARK: - Bookmark CRUD

    /// 북마크 토글
    func toggleBookmark(userUid: String, placeUid: String, completion: @escaping (Bool) -> Void) {
        BookmarkDAO.toggle(userUid: userUid, placeUid: placeUid, context: backgroundContext, completion: completion)
    }

    /// 북마크 여부 확인
    func isBookmarked(userUid: String, placeUid: String, completion: @escaping (Bool) -> Void) {
        BookmarkDAO.isBookmarked(userUid: userUid, placeUid: placeUid, context: backgroundContext, completion: completion)
    }

    /// 유저의 북마크 placeUID 목록
    func getUserBookmarkPlaceUids(userUid: String, completion: @escaping ([String]) -> Void) {
        BookmarkDAO.getUserBookmarkPlaceUids(userUid: userUid, context: backgroundContext, completion: completion)
    }

    // MARK: - Useful CRUD

    /// 도움돼요 토글
    func toggleUseful(userUid: String, reviewUid: String, completion: @escaping (Bool) -> Void) {
        UsefulDAO.toggle(userUid: userUid, reviewUid: reviewUid, context: backgroundContext, completion: completion)
    }

    /// 도움돼요 여부 확인
    func isUseful(userUid: String, reviewUid: String, completion: @escaping (Bool) -> Void) {
        UsefulDAO.isUseful(userUid: userUid, reviewUid: reviewUid, context: backgroundContext, completion: completion)
    }

    /// 유저의 도움돼요 reviewUID 목록
    func getUserUsefulReviewUids(userUid: String, completion: @escaping ([String]) -> Void) {
        UsefulDAO.getUserUsefulReviewUids(userUid: userUid, context: backgroundContext, completion: completion)
    }

    // MARK: - Quest Asset CRUD

    /// 오프라인 퀘스트 리소스 메타데이터 생성/업데이트
    func upsertQuestAsset(_ asset: QuestAssetDTO, completion: @escaping (Bool) -> Void) {
        QuestAssetDAO.upsert(asset, context: backgroundContext, completion: completion)
    }

    /// 퀘스트 리소스 단건 조회
    func readQuestAsset(assetId: String, completion: @escaping (QuestAssetDTO?) -> Void) {
        QuestAssetDAO.read(assetId: assetId, context: backgroundContext, completion: completion)
    }

    /// 특정 퀘스트에 필요한 리소스 목록 조회
    func readQuestAssets(questId: String, completion: @escaping ([QuestAssetDTO]) -> Void) {
        QuestAssetDAO.readAll(questId: questId, context: backgroundContext, completion: completion)
    }

    /// 퀘스트 리소스 메타데이터 삭제
    func deleteQuestAsset(assetId: String, completion: @escaping (Bool) -> Void) {
        QuestAssetDAO.delete(assetId: assetId, context: backgroundContext, completion: completion)
    }

}
