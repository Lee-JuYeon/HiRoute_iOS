//
//  ScheduleDB.swift
//  HiRoute
//
//  Created by Jupond on 12/29/25.
//

import CoreData

struct ScheduleDAO {
    private init() {}
    
    /// Schedule 생성 - 비동기
    static func create(_ schedule: ScheduleModel, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행, NSManagedObjectContext는 스레드 안전하지 않음, perform으로 전요ㅗㅇ 큐 에서 실행 보장. 메인 스레드 블로킹 방지.
            do {
                /*
                 중복검사 ( uid를 이용하여 중복검사, 동기식 헬퍼 사용 )
                 DB에 SELECT 쿼리 실행
                 있으면 조기종료
                 */
                if read(scheduleUID: schedule.uid, context: context) != nil {
                    print("ScheduleDAO, create // Warning : 이미 존재하는 일정 - \(schedule.uid)")
                    completion(false) // 중복이면 false를 completion으로 담아 보내고 return으로 종료
                    return
                }
                
                /*
                 메모리에만 Entity 객체 생성 (아직 DB에 저장 안됨)
                 NSManagedObject 인스턴스 생성
                 Context에 "삽입 대기" 상태로 등록
                 */
                _ = ScheduleEntityMapper.toEntity(schedule, context: context)

            
                // 영구 저장소에 저장
                try context.save()
                completion(true) // 성공
                print("ScheduleDAO, create // Success : 일정 저장 완료 - \(schedule.title)")
            } catch {
                completion(false)
                print("ScheduleDAO, create // Exception : \(error.localizedDescription)")
            }
        }
    }
    
    /// Schedule 업데이트 - 비동기
    static func update(_ schedule: ScheduleModel, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", schedule.uid)
                
                if let existingEntity = try context.fetch(request).first {
                    
                    // ✅ 기본 속성 업데이트
                    existingEntity.title = schedule.title
                    existingEntity.memo = schedule.memo
                    existingEntity.editDate = schedule.editDate
                    existingEntity.d_day = schedule.d_day
                    existingEntity.index = Int32(schedule.index)
                    
                    // ✅ Plan 디버깅 정보 출력
                    let existingPlans = existingEntity.planList as? Set<PlanEntity> ?? []
                    let existingUIDs = existingPlans.compactMap { $0.uid }
                    let newUIDs = schedule.planList.map { $0.uid }
                    
                    print("ScheduleDAO, update // DEBUG: 기존 Plan UIDs: \(existingUIDs)")
                    print("ScheduleDAO, update // DEBUG: 새로운 Plan UIDs: \(newUIDs)")
                    
                    // ✅ Plan 매핑
                    let existingPlanMap = [String: PlanEntity](uniqueKeysWithValues: existingPlans.compactMap {
                        guard let uid = $0.uid else { return nil }
                        return (uid, $0)
                    })
                    
                    let newPlanUIDs = Set(schedule.planList.map { $0.uid })
                    
                    // ✅ 삭제할 Plan들 확인
                    let plansToDelete = existingPlans.filter { !newPlanUIDs.contains($0.uid ?? "") }
                    print("ScheduleDAO, update // DEBUG: 삭제할 Plan UIDs: \(plansToDelete.compactMap { $0.uid })")
                    
                    // [2026-05-26 Phase 3] soft delete — 7일 grace period.
                    // relationship에서 떼지 않음 (그러면 fetch 시에도 안 보임). deletedAt만 세팅.
                    // Mapper의 deletedAt == nil 필터로 활성만 UI에 노출. GC가 7일 후 hard delete.
                    let now = Date()
                    plansToDelete.forEach { planEntity in
                        planEntity.deletedAt = now
                    }
                    print("ScheduleDAO, update // Info: \(plansToDelete.count)개 Plan soft-deleted")
                    
                    // ✅ 추가/업데이트 처리
                    var addedCount = 0
                    var updatedCount = 0
                    
                    for newPlan in schedule.planList {
                        if let existingPlan = existingPlanMap[newPlan.uid] {
                            // 기존 Plan 업데이트
                            existingPlan.index = Int32(newPlan.index)
                            existingPlan.memo = newPlan.memo
                            
                            // [2026-05-26 Phase 3] 파일도 soft delete — 신규 file 목록과 비교해
                            // 기존엔 있고 신규엔 없는 것만 deletedAt 세팅. 이미 deletedAt 세팅된
                            // (이전에 삭제된) 파일은 그대로 둠. 신규에 같은 uid가 다시 들어오면
                            // deletedAt 해제 (복구 시나리오).
                            let now = Date()
                            let newFileIDs = Set(newPlan.files.map { $0.id.uuidString })
                            if let existingFiles = existingPlan.files as? Set<FileEntity> {
                                for file in existingFiles where file.deletedAt == nil {
                                    if !newFileIDs.contains(file.id ?? "") {
                                        file.deletedAt = now
                                    }
                                }
                            }

                            // 새 파일들 추가 (이미 같은 uid로 있으면 deletedAt 해제 = 복구)
                            let existingFileIDs = Set((existingPlan.files as? Set<FileEntity>)?.compactMap { $0.id } ?? [])
                            let filesToAdd = newPlan.files.filter { !existingFileIDs.contains($0.id.uuidString) }
                            let newFileEntities = FileEntityMapper.toEntitiesForPlan(filesToAdd, planEntity: existingPlan, context: context)
                            for fileEntity in newFileEntities {
                                existingPlan.addToFiles(fileEntity)
                            }
                            // 이미 있던 파일 중 신규 목록에도 있으면 복구
                            if let existingFiles = existingPlan.files as? Set<FileEntity> {
                                for file in existingFiles where file.deletedAt != nil {
                                    if newFileIDs.contains(file.id ?? "") {
                                        file.deletedAt = nil
                                    }
                                }
                            }

                            updatedCount += 1
                            print("ScheduleDAO, update // DEBUG: Plan 업데이트 (파일 포함, soft delete) - \(newPlan.uid)")

                        } else {
                            // 새 Plan 추가
                            let newPlanEntity = PlanEntityMapper.toEntity(newPlan, schedule: existingEntity, context: context)
                            existingEntity.addToPlanList(newPlanEntity)
                            addedCount += 1
                            print("ScheduleDAO, update // DEBUG: Plan 추가 - \(newPlan.uid)")
                        }
                    }
                    
                    print("ScheduleDAO, update // Info: Plan 추가 \(addedCount)개, 업데이트 \(updatedCount)개")

                    // ✅ ChatHistory 동기화 (replace-all 패턴)
                    let existingChatMessages = existingEntity.chatHistory as? Set<ScheduleChatEntity> ?? []
                    let existingChatUIDs = Set(existingChatMessages.compactMap { $0.uid })
                    let newChatUIDs = Set(schedule.chatHistory.map { $0.uid })

                    // [2026-05-26 GUARD] 데이터 손실 1차 방어선 (랄프 루프 Phase 1).
                    // 호출부가 chatHistory 누락 → 빈 배열로 전달 → replace-all이 기존을 wipe하던 치명 버그.
                    // 의도적으로 전체 chat 삭제하는 케이스는 현재 없음. 따라서:
                    //   - 새 모델 chatHistory가 비었는데 기존엔 있으면 → wipe 거부 + Warning log.
                    //   - 의도적 전체 삭제가 필요해지면 별도 `clearChatHistory(scheduleUID:)` 메서드 추가 권장.
                    let isAccidentalWipe = schedule.chatHistory.isEmpty && !existingChatMessages.isEmpty
                    if isAccidentalWipe {
                        print("ScheduleDAO, update // Warning : chatHistory wipe 거부 - 호출부가 빈 배열 전달했으나 기존 \(existingChatMessages.count)개 보존. 호출부의 ScheduleModel 재구성 시 chatHistory 누락 의심.")
                    } else {
                        // [2026-05-26 Phase 3] soft delete — relationship 유지, deletedAt만 세팅.
                        let now = Date()
                        let chatsToDelete = existingChatMessages.filter {
                            $0.deletedAt == nil && !newChatUIDs.contains($0.uid ?? "")
                        }
                        chatsToDelete.forEach { chatEntity in
                            chatEntity.deletedAt = now
                        }

                        // 대량 삭제 audit log (≥3건)
                        if chatsToDelete.count >= 3 {
                            AuditLogService.shared.logBulkChatDeletion(
                                scheduleUID: schedule.uid,
                                deletedCount: chatsToDelete.count
                            )
                        }

                        // 추가/복구: 새 모델엔 있는데 기존 active엔 없는 메시지
                        let activeChatUIDs = Set(existingChatMessages.filter { $0.deletedAt == nil }.compactMap { $0.uid })
                        for newMessage in schedule.chatHistory {
                            if activeChatUIDs.contains(newMessage.uid) { continue }
                            // 기존에 soft-deleted였으면 복구
                            if let existing = existingChatMessages.first(where: { $0.uid == newMessage.uid && $0.deletedAt != nil }) {
                                existing.deletedAt = nil
                                continue
                            }
                            // 진짜 신규
                            let chatEntity = ScheduleChatEntityMapper.toEntity(newMessage, schedule: existingEntity, context: context)
                            existingEntity.addToChatHistory(chatEntity)
                        }
                        print("ScheduleDAO, update // Info: ChatHistory soft-delete \(chatsToDelete.count)개")
                    }

                    try context.save()
                    completion(true)
                    print("ScheduleDAO, update // Success: 일정 업데이트 완료")
                    
                } else {
                    completion(false)
                    print("ScheduleDAO, update // Warning: 업데이트할 일정을 찾을 수 없음")
                }
            } catch {
                completion(false)
                print("ScheduleDAO, update // Exception: \(error)")
            }
        }
    }
    /// Schedule 삭제 - 비동기
    /// [2026-05-26 Phase 3] soft delete — 7일 후 GC가 hard delete.
    /// 사용자가 삭제 후 복구 원할 수 있으므로 즉시 hard delete 안 함.
    static func delete(scheduleUID: String, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", scheduleUID)

                if let entity = try context.fetch(request).first {
                    entity.deletedAt = Date()
                    try context.save()
                    completion(true)
                    print("ScheduleDAO, delete // Success : 일정 soft-deleted - \(scheduleUID)")
                } else {
                    completion(false)
                    print("ScheduleDAO, delete // Warning : 일정을 찾을 수 없음 - \(scheduleUID)")
                }
            } catch {
                completion(false)
                print("ScheduleDAO, delete // Exception : \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - [2026-05-26 Phase 3] Recovery helpers

    /// 복구 화면이 사용하는 모델 — soft-deleted 항목 1건.
    struct DeletedItem {
        let scheduleUID: String
        let scheduleTitle: String
        let kind: Kind
        let deletedAt: Date
        let preview: String         // chat content / plan title / file name 등
        let entityUID: String       // 복구할 row의 uid

        enum Kind: String {
            case schedule
            case plan
            case chat
            case file
        }
    }

    /// 복구 화면 데이터. 모든 entity의 soft-deleted row를 한 번에 모음.
    static func loadDeletedItems(context: NSManagedObjectContext, completion: @escaping ([DeletedItem]) -> Void) {
        context.perform {
            var items: [DeletedItem] = []

            // Schedule 자체 (active schedule의 deletedAt도 보려면 predicate에 deletedAt != nil)
            let scheduleReq: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
            scheduleReq.predicate = NSPredicate(format: "deletedAt != nil")
            let deletedSchedules = (try? context.fetch(scheduleReq)) ?? []
            for entity in deletedSchedules {
                guard let uid = entity.uid, let deletedAt = entity.deletedAt else { continue }
                items.append(DeletedItem(
                    scheduleUID: uid,
                    scheduleTitle: entity.title ?? "(제목 없음)",
                    kind: .schedule,
                    deletedAt: deletedAt,
                    preview: "일정 전체",
                    entityUID: uid
                ))
            }

            // Chat
            let chatReq: NSFetchRequest<ScheduleChatEntity> = ScheduleChatEntity.fetchRequest()
            chatReq.predicate = NSPredicate(format: "deletedAt != nil")
            let deletedChats = (try? context.fetch(chatReq)) ?? []
            for entity in deletedChats {
                guard let uid = entity.uid, let deletedAt = entity.deletedAt else { continue }
                items.append(DeletedItem(
                    scheduleUID: entity.schedule?.uid ?? "",
                    scheduleTitle: entity.schedule?.title ?? "(일정 없음)",
                    kind: .chat,
                    deletedAt: deletedAt,
                    preview: entity.content ?? "",
                    entityUID: uid
                ))
            }

            // Plan
            let planReq: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
            planReq.predicate = NSPredicate(format: "deletedAt != nil")
            let deletedPlans = (try? context.fetch(planReq)) ?? []
            for entity in deletedPlans {
                guard let uid = entity.uid, let deletedAt = entity.deletedAt else { continue }
                let title = entity.placeModel?.title ?? entity.memo ?? "(장소 없음)"
                items.append(DeletedItem(
                    scheduleUID: entity.schedule?.uid ?? "",
                    scheduleTitle: entity.schedule?.title ?? "(일정 없음)",
                    kind: .plan,
                    deletedAt: deletedAt,
                    preview: title,
                    entityUID: uid
                ))
            }

            // File
            let fileReq: NSFetchRequest<FileEntity> = FileEntity.fetchRequest()
            fileReq.predicate = NSPredicate(format: "deletedAt != nil")
            let deletedFiles = (try? context.fetch(fileReq)) ?? []
            for entity in deletedFiles {
                guard let uid = entity.id, let deletedAt = entity.deletedAt else { continue }
                items.append(DeletedItem(
                    scheduleUID: entity.visitPlace?.schedule?.uid ?? "",
                    scheduleTitle: entity.visitPlace?.schedule?.title ?? "(일정 없음)",
                    kind: .file,
                    deletedAt: deletedAt,
                    preview: entity.fileName ?? "(파일명 없음)",
                    entityUID: uid
                ))
            }

            // 최신 삭제순
            items.sort { $0.deletedAt > $1.deletedAt }
            completion(items)
        }
    }

    /// 복구 — entityUID와 kind로 deletedAt = nil 처리.
    static func restore(item: DeletedItem, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                switch item.kind {
                case .schedule:
                    let req: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                    req.predicate = NSPredicate(format: "uid == %@", item.entityUID)
                    if let entity = try context.fetch(req).first {
                        entity.deletedAt = nil
                    }
                case .chat:
                    let req: NSFetchRequest<ScheduleChatEntity> = ScheduleChatEntity.fetchRequest()
                    req.predicate = NSPredicate(format: "uid == %@", item.entityUID)
                    if let entity = try context.fetch(req).first {
                        entity.deletedAt = nil
                    }
                case .plan:
                    let req: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                    req.predicate = NSPredicate(format: "uid == %@", item.entityUID)
                    if let entity = try context.fetch(req).first {
                        entity.deletedAt = nil
                    }
                case .file:
                    let req: NSFetchRequest<FileEntity> = FileEntity.fetchRequest()
                    req.predicate = NSPredicate(format: "id == %@", item.entityUID)
                    if let entity = try context.fetch(req).first {
                        entity.deletedAt = nil
                    }
                }
                try context.save()
                completion(true)
                print("ScheduleDAO, restore // Success : \(item.kind.rawValue) \(item.entityUID)")
            } catch {
                completion(false)
                print("ScheduleDAO, restore // Exception : \(error.localizedDescription)")
            }
        }
    }

    /// Schedule 조회 - 비동기
    static func read(scheduleUID: String, context: NSManagedObjectContext, completion: @escaping (ScheduleModel?) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                // fetch request 생성
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                // [2026-05-26 Phase 3] soft-deleted 일정 제외.
                request.predicate = NSPredicate(format: "uid == %@ AND deletedAt == nil", scheduleUID)

                if let entity = try context.fetch(request).first {
                    let schedule = ScheduleEntityMapper.toModel(entity)
                    completion(schedule)
                    print("ScheduleDAO, read // Success : 일정 조회 완료 - \(scheduleUID)")
                } else {
                    completion(nil)
                }
            } catch {
                print("ScheduleDAO, read // Exception : \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    /// 모든 Schedule 조회 - 비동기
    static func readAll(context: NSManagedObjectContext, completion: @escaping ([ScheduleModel]) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                // fetch request 생성
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                // [2026-05-26 Phase 3] soft-deleted 일정 제외 (deletedAt == nil)
                request.predicate = NSPredicate(format: "deletedAt == nil")
                // 최신 편집순 (edit date)
                request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]

                // core data에서 모든 entity 조회
                let entities = try context.fetch(request)

                // entity -> model 변환
                let schedules = entities.compactMap { ScheduleEntityMapper.toModel($0) }
                print("ScheduleDAO, readAll // Success : 일정 목록 조회 완료 - \(entities.count)개")
                
                // model list 반환
                completion(schedules)
            } catch {
                print("ScheduleDAO, readAll // Exception : \(error.localizedDescription)")
                completion([]) // 실패시 empty list 반환
            }
        }
    }
    
    /// [2026-05-26 Phase 2] 메타 필드만 업데이트 (title/memo/dDay/editDate).
    /// planList/chatHistory는 절대 안 건드림 — wipe 사고 재발 방지.
    /// updateScheduleInfo 같이 "제목/날짜만 바꾸는" 호출은 이 메서드만 써야 함.
    static func updateMeta(scheduleUID: String, title: String, memo: String, dDay: Date, editDate: Date, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", scheduleUID)

                if let entity = try context.fetch(request).first {
                    entity.title = title
                    entity.memo = memo
                    entity.d_day = dDay
                    entity.editDate = editDate
                    try context.save()
                    completion(true)
                    print("ScheduleDAO, updateMeta // Success : 메타 업데이트 완료 - \(scheduleUID)")
                } else {
                    completion(false)
                    print("ScheduleDAO, updateMeta // Warning : Schedule을 찾을 수 없음 - \(scheduleUID)")
                }
            } catch {
                completion(false)
                print("ScheduleDAO, updateMeta // Exception : \(error.localizedDescription)")
            }
        }
    }

    /// Schedule 인덱스만 업데이트 - 비동기
    static func updateIndex(scheduleUID: String, newIndex: Int, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", scheduleUID)

                if let entity = try context.fetch(request).first {
                    entity.index = Int32(newIndex)
                    try context.save()
                    print("ScheduleDAO, updateIndex // Success : Schedule 인덱스 업데이트 완료 - \(scheduleUID) → \(newIndex)")
                    completion(true)
                } else {
                    print("ScheduleDAO, updateIndex // Warning : Schedule을 찾을 수 없음 - \(scheduleUID)")
                    completion(false)
                }
            } catch {
                print("ScheduleDAO, updateIndex // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    /// 채팅 메시지 한 건만 Schedule.chatHistory에 추가 (전체 schedule update 안 함)
    static func appendChatMessage(scheduleUID: String, message: ChatMessageModel, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", scheduleUID)

                guard let scheduleEntity = try context.fetch(request).first else {
                    print("ScheduleDAO, appendChatMessage // Warning : Schedule 없음 - \(scheduleUID)")
                    completion(false)
                    return
                }

                let messageEntity = ScheduleChatEntityMapper.toEntity(message, schedule: scheduleEntity, context: context)
                scheduleEntity.addToChatHistory(messageEntity)
                try context.save()
                completion(true)
            } catch {
                print("ScheduleDAO, appendChatMessage // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    // MARK: - Helper Methods (동기식 - context.perform 내부에서만 호출)
    private static func read(scheduleUID: String, context: NSManagedObjectContext) -> ScheduleModel? {
        do {
            /*
             SELECT SQL 쿼리
             CoreData의 NSFetchRequest는 ORM(Object-Relational Mapping)
             
             ScheduleEntity.fetchRequest() → SELECT * FROM ZSCHEDULEENTITY
             NSPredicate(format: "uid == %@", schedule.uid) → WHERE ZUID = ?
             
             비유:
             fetchRequest() = 음식 주문서 작성
             fetch() = 주방에서 요리해서 가져오기

             메모리 관점:
             fetchRequest(): 0바이트 (객체만 생성)
             fetch(): 조회된 데이터만큼 메모리 사용
             
             fetch(): DB에서 읽어서 메모리에 로드
             save(): 모든 변경사항 한번에 커밋.
             */
            let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "uid == %@", scheduleUID)
            
            if let entity = try context.fetch(request).first { //여기서 SQL 실행
                return ScheduleEntityMapper.toModel(entity)
            }
            return nil
        } catch {
            print("ScheduleDAO, read // Exception : \(error.localizedDescription)")
            return nil
        }
    }
    
   
}
