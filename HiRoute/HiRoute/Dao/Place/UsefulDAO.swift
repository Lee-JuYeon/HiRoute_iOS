//
//  UsefulDAO.swift
//  HiRoute
//
//  Created by Jupond on 3/6/26.
//

import CoreData

/// 도움돼요 독립 저장/조회 (ReviewEntity 관계 없이 reviewUID 기반)
struct UsefulDAO {
    private init() {}

    /// 도움돼요 토글 (존재하면 삭제, 없으면 생성)
    /// - Returns: true = 추가됨, false = 제거됨
    static func toggle(userUid: String, reviewUid: String, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<UsefulEntity> = UsefulEntity.fetchRequest()
                request.predicate = NSPredicate(format: "userUID == %@ AND reviewUID == %@", userUid, reviewUid)

                if let existing = try context.fetch(request).first {
                    context.delete(existing)
                    try context.save()
                    print("UsefulDAO, toggle // Success : 도움돼요 제거 - \(reviewUid)")
                    completion(false)
                } else {
                    let entity = UsefulEntity(context: context)
                    entity.userUID = userUid
                    entity.reviewUID = reviewUid
                    try context.save()
                    print("UsefulDAO, toggle // Success : 도움돼요 추가 - \(reviewUid)")
                    completion(true)
                }
            } catch {
                print("UsefulDAO, toggle // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    /// 도움돼요 여부 확인
    static func isUseful(userUid: String, reviewUid: String, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<UsefulEntity> = UsefulEntity.fetchRequest()
                request.predicate = NSPredicate(format: "userUID == %@ AND reviewUID == %@", userUid, reviewUid)
                request.fetchLimit = 1
                let count = try context.count(for: request)
                completion(count > 0)
            } catch {
                print("UsefulDAO, isUseful // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    /// 유저의 도움돼요 reviewUID 목록 조회
    static func getUserUsefulReviewUids(userUid: String, context: NSManagedObjectContext, completion: @escaping ([String]) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<UsefulEntity> = UsefulEntity.fetchRequest()
                request.predicate = NSPredicate(format: "userUID == %@", userUid)
                let entities = try context.fetch(request)
                let reviewUids = entities.compactMap { $0.reviewUID }
                print("UsefulDAO, getUserUsefulReviewUids // Success : \(reviewUids.count)개 조회")
                completion(reviewUids)
            } catch {
                print("UsefulDAO, getUserUsefulReviewUids // Exception : \(error.localizedDescription)")
                completion([])
            }
        }
    }
}
