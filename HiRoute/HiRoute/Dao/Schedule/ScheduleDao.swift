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
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", schedule.uid)
                
                if let existingEntity = try context.fetch(request).first {
                    // 기존 관계 데이터 삭제
                    if let plans = existingEntity.planList as? Set<PlanEntity> {
                        for plan in plans {
                            // 기존 데이터 삭제후 재생성하는 방식으로 업데이트 진행하기 위해 삭제.
                            context.delete(plan)
                        }
                    }
                    
                    // 2. 기본 속성 직접 업데이트
                    existingEntity.title = schedule.title
                    existingEntity.memo = schedule.memo
                    existingEntity.editDate = schedule.editDate
                    existingEntity.d_day = schedule.d_day
                    existingEntity.index = Int32(schedule.index)
                    
                    // 새 Plan들 추가
                    for plan in schedule.planList {
                        let planEntity = PlanEntityMapper.toEntity(plan, schedule: existingEntity, context: context)
                        existingEntity.addToPlanList(planEntity)
                    }
                    
                    try context.save()
                    completion(true)
                    print("ScheduleDAO, update // Success : 일정 업데이트 완료 - \(schedule.title)")
                } else {
                    completion(false)
                    print("ScheduleDAO, update // Warning : 업데이트할 일정을 찾을 수 없음")
                }
            } catch {
                completion(false)
                print("ScheduleDAO, update // Exception : \(error.localizedDescription)")
            }
        }
    }
    
    /// Schedule 삭제 - 비동기
    static func delete(scheduleUID: String, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", scheduleUID)
                
                if let entity = try context.fetch(request).first {
                    context.delete(entity)
                    try context.save()
                    completion(true)
                    print("ScheduleDAO, delete // Success : 일정 삭제 완료 - \(scheduleUID)")
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
    
    /// Schedule 조회 - 비동기
    static func read(scheduleUID: String, context: NSManagedObjectContext, completion: @escaping (ScheduleModel?) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                // fetch request 생성
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", scheduleUID)
                
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
                // 최신 편집순 (edit date)
                request.sortDescriptors = [NSSortDescriptor(key: "editDate", ascending: false)]
                
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
